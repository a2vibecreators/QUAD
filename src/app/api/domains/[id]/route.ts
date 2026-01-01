/**
 * GET /api/domains/[id] - Get domain by ID
 * PUT /api/domains/[id] - Update domain
 * DELETE /api/domains/[id] - Delete domain
 */

import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/db';
import { verifyToken } from '@/lib/auth';

interface RouteParams {
  params: Promise<{ id: string }>;
}

// GET: Get domain by ID with full details
export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = await params;

    // Verify authentication
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const token = authHeader.substring(7);
    const payload = verifyToken(token);
    if (!payload) {
      return NextResponse.json({ error: 'Invalid token' }, { status: 401 });
    }

    const domain = await prisma.qUAD_domains.findUnique({
      where: { id },
      include: {
        parent_domain: {
          select: { id: true, name: true, path: true }
        },
        sub_domains: {
          select: {
            id: true,
            name: true,
            domain_type: true,
            _count: { select: { members: true, flows: true } }
          }
        },
        members: {
          include: {
            user: {
              select: { id: true, email: true, full_name: true, role: true }
            }
          }
        },
        resources: {
          select: {
            id: true,
            resource_type: true,
            resource_name: true,
            resource_status: true
          }
        },
        circles: {
          select: {
            id: true,
            circle_number: true,
            circle_name: true,
            is_active: true
          }
        },
        _count: {
          select: {
            members: true,
            resources: true,
            flows: true,
            circles: true,
            sub_domains: true
          }
        }
      }
    });

    if (!domain) {
      return NextResponse.json({ error: 'Domain not found' }, { status: 404 });
    }

    // Verify domain belongs to user's company
    if (domain.company_id !== payload.companyId) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    return NextResponse.json(domain);
  } catch (error) {
    console.error('Get domain error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// PUT: Update domain
export async function PUT(request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = await params;

    // Verify authentication
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const token = authHeader.substring(7);
    const payload = verifyToken(token);
    if (!payload) {
      return NextResponse.json({ error: 'Invalid token' }, { status: 401 });
    }

    // Only admins and managers can update domains
    if (!['ADMIN', 'MANAGER'].includes(payload.role)) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    // Check if domain exists
    const existing = await prisma.qUAD_domains.findUnique({
      where: { id }
    });

    if (!existing) {
      return NextResponse.json({ error: 'Domain not found' }, { status: 404 });
    }

    if (existing.company_id !== payload.companyId) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    const body = await request.json();
    const { name, domain_type, parent_domain_id } = body;

    // If changing parent, recalculate path
    let newPath = existing.path;
    if (parent_domain_id !== undefined && parent_domain_id !== existing.parent_domain_id) {
      if (parent_domain_id === null) {
        newPath = `/${name || existing.name}`;
      } else {
        const parentDomain = await prisma.qUAD_domains.findUnique({
          where: { id: parent_domain_id }
        });
        if (parentDomain && parentDomain.company_id === payload.companyId) {
          newPath = `${parentDomain.path || ''}/${name || existing.name}`;
        }
      }
    } else if (name && name !== existing.name && existing.path) {
      // Just update name in path
      const pathParts = existing.path.split('/');
      pathParts[pathParts.length - 1] = name;
      newPath = pathParts.join('/');
    }

    const domain = await prisma.qUAD_domains.update({
      where: { id },
      data: {
        ...(name && { name }),
        ...(domain_type !== undefined && { domain_type }),
        ...(parent_domain_id !== undefined && { parent_domain_id }),
        path: newPath
      }
    });

    return NextResponse.json(domain);
  } catch (error) {
    console.error('Update domain error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// DELETE: Delete domain
export async function DELETE(request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = await params;

    // Verify authentication
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const token = authHeader.substring(7);
    const payload = verifyToken(token);
    if (!payload) {
      return NextResponse.json({ error: 'Invalid token' }, { status: 401 });
    }

    // Only admins can delete domains
    if (payload.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    // Check if domain exists
    const existing = await prisma.qUAD_domains.findUnique({
      where: { id },
      include: {
        _count: { select: { sub_domains: true } }
      }
    });

    if (!existing) {
      return NextResponse.json({ error: 'Domain not found' }, { status: 404 });
    }

    if (existing.company_id !== payload.companyId) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    // Warn if domain has sub-domains
    if (existing._count.sub_domains > 0) {
      return NextResponse.json(
        { error: 'Cannot delete domain with sub-domains. Delete sub-domains first.' },
        { status: 400 }
      );
    }

    await prisma.qUAD_domains.delete({
      where: { id }
    });

    return NextResponse.json({ message: 'Domain deleted successfully' });
  } catch (error) {
    console.error('Delete domain error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
