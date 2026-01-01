'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function SignupPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const [formData, setFormData] = useState({
    companyName: '',
    adminEmail: '',
    companySize: 'medium',
    ssoProvider: '',
    message: '',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);

    try {
      const response = await fetch('/api/auth/request-access', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Request failed');
      }

      setSuccess(true);
    } catch (err: any) {
      setError(err.message || 'Something went wrong');
    } finally {
      setIsLoading(false);
    }
  };

  const handleChange = (
    e: React.ChangeEvent<
      HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement
    >
  ) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  if (success) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 p-4">
        <div className="max-w-md w-full space-y-8 bg-white rounded-2xl shadow-2xl p-8 text-center">
          {/* Success Icon */}
          <div className="flex justify-center">
            <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center">
              <svg
                className="w-10 h-10 text-green-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M5 13l4 4L19 7"
                />
              </svg>
            </div>
          </div>

          {/* Success Message */}
          <div>
            <h2 className="text-2xl font-bold text-gray-900 mb-2">
              Request Submitted!
            </h2>
            <p className="text-gray-600 mb-6">
              We've received your access request for QUAD Platform.
            </p>
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 text-left">
              <p className="text-sm text-blue-900 font-medium mb-2">
                What happens next?
              </p>
              <ul className="text-sm text-blue-800 space-y-2">
                <li className="flex items-start gap-2">
                  <span className="text-blue-600 mt-0.5">•</span>
                  <span>
                    Our team will review your request within 24 hours
                  </span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-blue-600 mt-0.5">•</span>
                  <span>
                    You'll receive setup instructions at{' '}
                    <strong>{formData.adminEmail}</strong>
                  </span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-blue-600 mt-0.5">•</span>
                  <span>
                    Self-hosted deployment typically takes 1-2 hours
                  </span>
                </li>
              </ul>
            </div>
          </div>

          {/* Action Button */}
          <button
            onClick={() => router.push('/')}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 rounded-lg transition-colors"
          >
            Back to Home
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 p-4">
      <div className="max-w-2xl w-full space-y-8 bg-white rounded-2xl shadow-2xl p-8">
        {/* Header */}
        <div className="text-center">
          <div className="flex justify-center mb-4">
            <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center shadow-lg">
              <span className="text-white font-bold text-3xl">Q</span>
            </div>
          </div>
          <h2 className="text-3xl font-bold text-gray-900">
            Request QUAD Platform Access
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            Self-hosted enterprise AI development platform
          </p>
        </div>

        {/* Pricing Info */}
        <div className="bg-gradient-to-r from-blue-50 to-purple-50 border border-blue-200 rounded-lg p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="font-semibold text-gray-900">Free Tier Available</p>
              <p className="text-sm text-gray-600">
                Up to 5 users • Full feature access • Self-hosted
              </p>
            </div>
            <div className="text-right">
              <p className="text-2xl font-bold text-blue-600">$0</p>
              <p className="text-xs text-gray-500">forever</p>
            </div>
          </div>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Company Name */}
          <div>
            <label
              htmlFor="companyName"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Company Name *
            </label>
            <input
              type="text"
              id="companyName"
              name="companyName"
              required
              value={formData.companyName}
              onChange={handleChange}
              placeholder="Massachusetts Mutual Life Insurance"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          {/* Admin Email */}
          <div>
            <label
              htmlFor="adminEmail"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Admin Email Address *
            </label>
            <input
              type="email"
              id="adminEmail"
              name="adminEmail"
              required
              value={formData.adminEmail}
              onChange={handleChange}
              placeholder="admin@massmutual.com"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            <p className="mt-1 text-xs text-gray-500">
              This will be your QUAD_ADMIN account
            </p>
          </div>

          {/* Company Size */}
          <div>
            <label
              htmlFor="companySize"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Company Size *
            </label>
            <select
              id="companySize"
              name="companySize"
              required
              value={formData.companySize}
              onChange={handleChange}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="startup">Startup (1-50 employees)</option>
              <option value="medium">Medium (51-500 employees)</option>
              <option value="enterprise">Enterprise (500+ employees)</option>
            </select>
          </div>

          {/* SSO Provider */}
          <div>
            <label
              htmlFor="ssoProvider"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Preferred SSO Provider *
            </label>
            <select
              id="ssoProvider"
              name="ssoProvider"
              required
              value={formData.ssoProvider}
              onChange={handleChange}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="">Select your SSO provider</option>
              <option value="okta">Okta</option>
              <option value="azure-ad">Microsoft Azure AD</option>
              <option value="google">Google Workspace</option>
              <option value="github">GitHub Enterprise</option>
              <option value="auth0">Auth0</option>
              <option value="oidc">Generic OIDC (Custom)</option>
            </select>
            <p className="mt-1 text-xs text-gray-500">
              We'll configure this during setup
            </p>
          </div>

          {/* Message */}
          <div>
            <label
              htmlFor="message"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Additional Information (Optional)
            </label>
            <textarea
              id="message"
              name="message"
              rows={4}
              value={formData.message}
              onChange={handleChange}
              placeholder="Tell us about your use case, team structure, or any specific requirements..."
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
            />
          </div>

          {/* Error Message */}
          {error && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-3">
              <p className="text-sm text-red-800">{error}</p>
            </div>
          )}

          {/* Submit Button */}
          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white font-medium py-3 rounded-lg transition-all transform hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
          >
            {isLoading ? (
              <span className="flex items-center justify-center gap-2">
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Submitting...
              </span>
            ) : (
              'Request Access'
            )}
          </button>
        </form>

        {/* Footer */}
        <div className="text-center space-y-2 pt-4 border-t border-gray-200">
          <p className="text-xs text-gray-500">
            Already have an account?{' '}
            <a
              href="/auth/login"
              className="text-blue-600 hover:text-blue-700 font-medium"
            >
              Sign in
            </a>
          </p>
          <p className="text-xs text-gray-400">
            Questions? Email us at{' '}
            <a
              href="mailto:support@quadframe.work"
              className="text-blue-600 hover:text-blue-700"
            >
              support@quadframe.work
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}
