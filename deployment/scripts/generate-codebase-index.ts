#!/usr/bin/env npx ts-node
/**
 * CLI Script to Generate Codebase Index
 *
 * Usage:
 *   npx ts-node scripts/generate-codebase-index.ts <org_id> <repo_path> <repo_name>
 *
 * Example:
 *   npx ts-node scripts/generate-codebase-index.ts "org-uuid" "/path/to/quadframework" "quadframework"
 *
 * For QUAD Framework itself:
 *   npm run index:generate
 */

import { PrismaClient } from '../src/generated/prisma/index.js';
import * as fs from 'fs';
import * as path from 'path';

const prisma = new PrismaClient();

// Types
interface CodebaseIndex {
  tables: Record<string, string>;
  apis: Record<string, string>;
  files: Record<string, string>;
  components: Record<string, string>;
  patterns: Record<string, string>;
  architecture: string;
}

// Configuration
const IGNORE_DIRS = [
  'node_modules', '.git', '.next', 'dist', 'build',
  'coverage', '.turbo', '.vercel', 'generated'
];

const CODE_EXTENSIONS = ['.ts', '.tsx', '.js', '.jsx', '.prisma', '.sql', '.json'];

async function main() {
  const args = process.argv.slice(2);

  if (args.length < 3) {
    console.log(`
╔════════════════════════════════════════════════════════════════╗
║           QUAD Codebase Index Generator                        ║
╠════════════════════════════════════════════════════════════════╣
║                                                                 ║
║  Usage:                                                         ║
║    npx ts-node scripts/generate-codebase-index.ts \\            ║
║      <org_id> <repo_path> <repo_name>                           ║
║                                                                 ║
║  Example:                                                       ║
║    npx ts-node scripts/generate-codebase-index.ts \\            ║
║      "550e8400-e29b-41d4-a716-446655440000" \\                  ║
║      "/Users/dev/quadframework" \\                              ║
║      "quadframework"                                            ║
║                                                                 ║
║  This generates a token-optimized index of your codebase        ║
║  for AI context. Instead of 50K+ tokens, use ~500 tokens.       ║
║                                                                 ║
╚════════════════════════════════════════════════════════════════╝
`);
    process.exit(1);
  }

  const [orgId, repoPath, repoName] = args;

  console.log('\n🔍 QUAD Codebase Indexer\n');
  console.log(`Repository: ${repoName}`);
  console.log(`Path: ${repoPath}`);
  console.log(`Org ID: ${orgId}\n`);

  if (!fs.existsSync(repoPath)) {
    console.error(`❌ Path does not exist: ${repoPath}`);
    process.exit(1);
  }

  const index: CodebaseIndex = {
    tables: {},
    apis: {},
    files: {},
    components: {},
    patterns: {},
    architecture: ''
  };

  let locCount = 0;
  let fileCount = 0;

  // 1. Index Prisma schema
  console.log('📊 Indexing Prisma schema...');
  const schemaPath = path.join(repoPath, 'prisma', 'schema.prisma');
  if (fs.existsSync(schemaPath)) {
    const content = fs.readFileSync(schemaPath, 'utf-8');
    const modelRegex = /model\s+(\w+)\s*\{/g;
    let match;
    while ((match = modelRegex.exec(content)) !== null) {
      index.tables[match[1]] = 'Database table';
    }
    console.log(`   Found ${Object.keys(index.tables).length} tables`);
  }

  // 2. Index API routes
  console.log('🔌 Indexing API routes...');
  const apiPath = path.join(repoPath, 'src', 'app', 'api');
  if (fs.existsSync(apiPath)) {
    indexApiDir(apiPath, '', index.apis);
    console.log(`   Found ${Object.keys(index.apis).length} endpoints`);
  }

  // 3. Index source files
  console.log('📁 Indexing source files...');
  const srcPath = path.join(repoPath, 'src');
  if (fs.existsSync(srcPath)) {
    const result = indexSrcDir(srcPath, '', index.files, index.components);
    locCount = result.loc;
    fileCount = result.count;
    console.log(`   Indexed ${fileCount} files (${locCount} LOC)`);
  }

  // 4. Detect patterns
  console.log('🔧 Detecting tech stack...');
  const pkgPath = path.join(repoPath, 'package.json');
  if (fs.existsSync(pkgPath)) {
    const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf-8'));
    const deps = { ...pkg.dependencies, ...pkg.devDependencies };
    if (deps['next']) index.patterns['framework'] = 'Next.js App Router';
    if (deps['@prisma/client']) index.patterns['database'] = 'PostgreSQL via Prisma';
    if (deps['next-auth']) index.patterns['auth'] = 'NextAuth.js';
    if (deps['tailwindcss']) index.patterns['styling'] = 'Tailwind CSS';
    console.log(`   Detected ${Object.keys(index.patterns).length} patterns`);
  }

  // 5. Generate summary
  index.architecture = `${repoName}: ${Object.keys(index.tables).length} tables, ${Object.keys(index.apis).length} APIs, ${Object.keys(index.components).length} components`;

  // 6. Calculate tokens
  const indexJson = JSON.stringify(index);
  const totalTokens = Math.ceil(indexJson.length / 4);
  const fullCodeTokens = (fileCount * 500) + (Object.keys(index.tables).length * 100);
  const savings = Math.round((1 - totalTokens / fullCodeTokens) * 100);

  // 7. Get commit hash
  let commitHash: string | null = null;
  try {
    const gitHeadPath = path.join(repoPath, '.git', 'HEAD');
    if (fs.existsSync(gitHeadPath)) {
      const head = fs.readFileSync(gitHeadPath, 'utf-8').trim();
      if (head.startsWith('ref:')) {
        const refPath = path.join(repoPath, '.git', head.replace('ref: ', ''));
        if (fs.existsSync(refPath)) {
          commitHash = fs.readFileSync(refPath, 'utf-8').trim().substring(0, 40);
        }
      }
    }
  } catch { /* ignore */ }

  // 8. Save to database
  console.log('\n💾 Saving to database...');
  try {
    await prisma.qUAD_codebase_indexes.upsert({
      where: {
        org_id_repo_name_branch: {
          org_id: orgId,
          repo_name: repoName,
          branch: 'main'
        }
      },
      update: {
        commit_hash: commitHash,
        tables_summary: index.tables,
        apis_summary: index.apis,
        files_summary: index.files,
        components_summary: index.components,
        patterns_summary: index.patterns,
        architecture_summary: index.architecture,
        total_tokens: totalTokens,
        token_savings_percent: savings,
        file_count: fileCount,
        table_count: Object.keys(index.tables).length,
        api_count: Object.keys(index.apis).length,
        loc_count: locCount,
        last_synced_at: new Date(),
        sync_status: 'synced'
      },
      create: {
        org_id: orgId,
        repo_name: repoName,
        branch: 'main',
        commit_hash: commitHash,
        tables_summary: index.tables,
        apis_summary: index.apis,
        files_summary: index.files,
        components_summary: index.components,
        patterns_summary: index.patterns,
        architecture_summary: index.architecture,
        total_tokens: totalTokens,
        token_savings_percent: savings,
        file_count: fileCount,
        table_count: Object.keys(index.tables).length,
        api_count: Object.keys(index.apis).length,
        loc_count: locCount,
        last_synced_at: new Date(),
        sync_status: 'synced'
      }
    });

    console.log(`
╔════════════════════════════════════════════════════════════════╗
║                    ✅ INDEX GENERATED                          ║
╠════════════════════════════════════════════════════════════════╣
║                                                                 ║
║  Files indexed:    ${String(fileCount).padEnd(42)}║
║  Tables found:     ${String(Object.keys(index.tables).length).padEnd(42)}║
║  API routes:       ${String(Object.keys(index.apis).length).padEnd(42)}║
║  Components:       ${String(Object.keys(index.components).length).padEnd(42)}║
║  Lines of code:    ${String(locCount).padEnd(42)}║
║                                                                 ║
║  Index tokens:     ${String(totalTokens).padEnd(42)}║
║  Token savings:    ${String(savings + '%').padEnd(42)}║
║                                                                 ║
║  Commit:           ${(commitHash || 'N/A').substring(0, 42).padEnd(42)}║
║                                                                 ║
╚════════════════════════════════════════════════════════════════╝
`);
  } catch (error) {
    console.error('❌ Database error:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

function indexApiDir(dir: string, basePath: string, apis: Record<string, string>) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      const newBase = basePath + '/' + entry.name.replace(/\[(\w+)\]/g, ':$1');
      indexApiDir(fullPath, newBase, apis);
    } else if (entry.name === 'route.ts' || entry.name === 'route.js') {
      const content = fs.readFileSync(fullPath, 'utf-8');
      const routePath = basePath || '/';
      ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'].forEach(method => {
        if (content.includes(`function ${method}`)) {
          apis[`${method} /api${routePath}`] = 'API endpoint';
        }
      });
    }
  }
}

function indexSrcDir(
  dir: string,
  relativePath: string,
  files: Record<string, string>,
  components: Record<string, string>
): { loc: number; count: number } {
  let totalLoc = 0;
  let fileCount = 0;

  const entries = fs.readdirSync(dir, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    const relPath = relativePath ? `${relativePath}/${entry.name}` : entry.name;

    if (entry.isDirectory()) {
      if (!IGNORE_DIRS.includes(entry.name)) {
        const result = indexSrcDir(fullPath, relPath, files, components);
        totalLoc += result.loc;
        fileCount += result.count;
      }
    } else {
      const ext = path.extname(entry.name);
      if (!CODE_EXTENSIONS.includes(ext)) continue;

      fileCount++;
      const content = fs.readFileSync(fullPath, 'utf-8');
      totalLoc += content.split('\n').length;

      files[`src/${relPath}`] = 'Source file';

      if ((ext === '.tsx' || ext === '.jsx') &&
          content.includes('export')) {
        components[entry.name.replace(/\.(tsx|jsx)$/, '')] = 'React component';
      }
    }
  }

  return { loc: totalLoc, count: fileCount };
}

main().catch(console.error);
