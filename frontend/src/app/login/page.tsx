"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import toast from "react-hot-toast";
import { authApi } from "@/lib/api";
import { useAuthStore } from "@/store/auth";
import type { User } from "@/types";

export default function LoginPage() {
  const router = useRouter();
  const { setAuth } = useAuthStore();
  const [form, setForm] = useState({ email: "", password: "" });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await authApi.login(form);
      setAuth(res.data.user as User, res.data.access_token);
      toast.success("Welcome back!");
      router.push("/dashboard");
    } catch (err: unknown) {
      const error = err as { response?: { data?: { detail?: string } } };
      toast.error(error.response?.data?.detail || "Invalid credentials");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <Link href="/" className="text-3xl mb-4 inline-block">🏢</Link>
          <h1 className="text-2xl font-bold">Welcome back</h1>
          <p className="text-[#8888aa] mt-2">Sign in to your board of directors</p>
        </div>

        <div className="bg-[#12121a] border border-[#2a2a3d] rounded-2xl p-8">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1.5">Email</label>
              <input
                type="email"
                value={form.email}
                onChange={(e) => setForm({ ...form, email: e.target.value })}
                placeholder="you@example.com"
                required
                className="w-full bg-[#1a1a27] border border-[#2a2a3d] rounded-lg px-4 py-3 text-[#f0f0ff] placeholder-[#4a4a6a] focus:outline-none focus:border-[#6366f1] transition-colors"
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1.5">Password</label>
              <input
                type="password"
                value={form.password}
                onChange={(e) => setForm({ ...form, password: e.target.value })}
                placeholder="••••••••"
                required
                className="w-full bg-[#1a1a27] border border-[#2a2a3d] rounded-lg px-4 py-3 text-[#f0f0ff] placeholder-[#4a4a6a] focus:outline-none focus:border-[#6366f1] transition-colors"
              />
            </div>
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-[#6366f1] hover:bg-[#818cf8] disabled:opacity-50 text-white font-semibold py-3 rounded-lg transition-colors"
            >
              {loading ? "Signing in..." : "Sign In"}
            </button>
          </form>

          <p className="text-center text-[#8888aa] text-sm mt-6">
            Don&apos;t have an account?{" "}
            <Link href="/register" className="text-[#6366f1] hover:text-[#818cf8]">
              Create one
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
