/**
 * NextAuth.js OAuth SSO Configuration
 * Enterprise SSO Support: Okta, Azure AD, Google, GitHub, OneLogin, Auth0, SAML
 */

import NextAuth, { NextAuthOptions } from "next-auth";
import GoogleProvider from "next-auth/providers/google";
import GitHubProvider from "next-auth/providers/github";
import AzureADProvider from "next-auth/providers/azure-ad";
import OktaProvider from "next-auth/providers/okta";
import Auth0Provider from "next-auth/providers/auth0";
import { query } from "@/lib/db";

const authOptions = {
  providers: [
    // ============================================
    // ENTERPRISE SSO PROVIDERS (Most Common)
    // ============================================

    // 1. Okta (Mass Mutual, many Fortune 500 companies)
    ...(process.env.OKTA_CLIENT_ID ? [
      OktaProvider({
        clientId: process.env.OKTA_CLIENT_ID!,
        clientSecret: process.env.OKTA_CLIENT_SECRET!,
        issuer: process.env.OKTA_ISSUER!, // e.g., https://dev-12345.okta.com
      })
    ] : []),

    // 2. Microsoft Azure AD / Entra ID (Most enterprise companies)
    ...(process.env.AZURE_AD_CLIENT_ID ? [
      AzureADProvider({
        clientId: process.env.AZURE_AD_CLIENT_ID!,
        clientSecret: process.env.AZURE_AD_CLIENT_SECRET!,
        tenantId: process.env.AZURE_AD_TENANT_ID || "common",
      })
    ] : []),

    // 3. Auth0 (Popular SSO provider)
    ...(process.env.AUTH0_CLIENT_ID ? [
      Auth0Provider({
        clientId: process.env.AUTH0_CLIENT_ID!,
        clientSecret: process.env.AUTH0_CLIENT_SECRET!,
        issuer: process.env.AUTH0_ISSUER!, // e.g., https://yourcompany.auth0.com
      })
    ] : []),

    // ============================================
    // STANDARD OAUTH PROVIDERS
    // ============================================

    // 4. Google Workspace (Startups, SMBs)
    ...(process.env.GOOGLE_CLIENT_ID ? [
      GoogleProvider({
        clientId: process.env.GOOGLE_CLIENT_ID!,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
      })
    ] : []),

    // 5. GitHub (Developer teams)
    ...(process.env.GITHUB_CLIENT_ID ? [
      GitHubProvider({
        clientId: process.env.GITHUB_CLIENT_ID!,
        clientSecret: process.env.GITHUB_CLIENT_SECRET!,
      })
    ] : []),

    // ============================================
    // GENERIC OIDC PROVIDER (OneLogin, Ping Identity, etc.)
    // ============================================
    // TODO: Fix TypeScript typing for OIDC provider in Next.js 15
    // ...(process.env.OIDC_CLIENT_ID ? [{
    //   id: "oidc",
    //   name: process.env.OIDC_PROVIDER_NAME || "Enterprise SSO",
    //   type: "oauth" as const,
    //   wellKnown: process.env.OIDC_ISSUER + "/.well-known/openid-configuration",
    //   authorization: { params: { scope: "openid email profile" } },
    //   clientId: process.env.OIDC_CLIENT_ID!,
    //   clientSecret: process.env.OIDC_CLIENT_SECRET!,
    //   idToken: true,
    //   checks: ["pkce", "state"],
    //   profile(profile: any) {
    //     return {
    //       id: profile.sub,
    //       name: profile.name,
    //       email: profile.email,
    //       image: profile.picture,
    //     };
    //   },
    // }] : []),
  ],

  callbacks: {
    /**
     * Called after successful OAuth sign-in
     * Create or update user in database
     */
    async signIn({ user, account, profile }) {
      if (!account || !user.email) {
        return false;
      }

      try {
        // Check if user exists by email
        const existingUser = await query(
          'SELECT id, company_id, role FROM quad_users WHERE email = $1',
          [user.email]
        );

        if (existingUser.rows.length > 0) {
          // User exists - update OAuth info
          await query(
            `UPDATE quad_users
             SET oauth_provider = $1, oauth_id = $2, avatar_url = $3, last_login_at = NOW()
             WHERE email = $4`,
            [account.provider, account.providerAccountId, user.image, user.email]
          );
          return true;
        }

        // New user - check if they belong to existing company by email domain
        const emailDomain = user.email.split('@')[1];

        // Look for company with matching admin email domain
        const companyResult = await query(
          `SELECT id FROM quad_companies
           WHERE admin_email LIKE $1`,
          [`%@${emailDomain}`]
        );

        if (companyResult.rows.length > 0) {
          // Company exists - add user as team member
          // Check user count for free tier limit (5 users)
          const userCountResult = await query(
            'SELECT COUNT(*) as count FROM quad_users WHERE company_id = $1',
            [companyResult.rows[0].id]
          );

          const userCount = parseInt(userCountResult.rows[0].count);

          if (userCount >= 5) {
            // Check if company has paid plan
            const companyPlanResult = await query(
              'SELECT size FROM quad_companies WHERE id = $1',
              [companyResult.rows[0].id]
            );

            // For now, allow if size is not 'startup' (pro/enterprise plans)
            if (companyPlanResult.rows[0].size === 'startup') {
              console.log(`Sign-in rejected: Free tier limit (5 users) reached for ${user.email}`);
              return '/upgrade?reason=user-limit'; // Redirect to upgrade page
            }
          }

          // Add user
          await query(
            `INSERT INTO quad_users (
              company_id, email, oauth_provider, oauth_id,
              full_name, avatar_url, role, is_active, email_verified
            ) VALUES ($1, $2, $3, $4, $5, $6, 'DEVELOPER', true, true)`,
            [
              companyResult.rows[0].id,
              user.email,
              account.provider,
              account.providerAccountId,
              user.name,
              user.image,
            ]
          );
          return true;
        } else {
          // No company found - user must be invited first
          console.log(`Sign-in rejected: No company found for ${user.email}`);
          return '/signup?reason=no-company&email=' + encodeURIComponent(user.email);
        }

      } catch (error) {
        console.error('Sign-in callback error:', error);
        return false;
      }
    },

    /**
     * Add custom user data to JWT token
     */
    async jwt({ token, user, account }) {
      if (account && user) {
        // Fetch user data from database
        const userResult = await query(
          `SELECT id, company_id, role, full_name FROM quad_users WHERE email = $1`,
          [user.email]
        );

        if (userResult.rows.length > 0) {
          const dbUser = userResult.rows[0];
          token.userId = dbUser.id;
          token.companyId = dbUser.company_id;
          token.role = dbUser.role;
          token.fullName = dbUser.full_name;

          // NEW: Fetch domain membership (if exists)
          // Note: Domain membership is optional - user can work without being assigned to a domain
          const domainResult = await query(
            `SELECT
              dm.domain_id,
              dm.role as domain_role,
              dm.allocation_percentage
            FROM quad_domain_members dm
            WHERE dm.user_id = $1
            ORDER BY dm.created_at ASC
            LIMIT 1`,
            [dbUser.id]
          );

          if (domainResult.rows.length > 0) {
            const domainMembership = domainResult.rows[0];
            token.domainId = domainMembership.domain_id;
            token.domainRole = domainMembership.domain_role;
            token.allocationPercentage = domainMembership.allocation_percentage;
          }
        }
      }
      return token;
    },

    /**
     * Add custom data to session
     */
    async session({ session, token }) {
      if (token && session.user) {
        session.user.id = token.userId as string;
        session.user.companyId = token.companyId as string;
        session.user.role = token.role as string;
        session.user.fullName = token.fullName as string;

        // NEW: Add domain context
        session.user.domainId = token.domainId as string;
        session.user.domainRole = token.domainRole as string;
        session.user.allocationPercentage = token.allocationPercentage as number;
      }
      return session;
    },
  },

  pages: {
    signIn: '/auth/login',
    error: '/auth/login',
    newUser: '/auth/select-domain', // Redirect new users to domain selection
  },

  session: {
    strategy: 'jwt',
    maxAge: 24 * 60 * 60, // 24 hours
  },

  secret: process.env.NEXTAUTH_SECRET!,
} satisfies NextAuthOptions;

const handler = NextAuth(authOptions);

export { handler as GET, handler as POST };
