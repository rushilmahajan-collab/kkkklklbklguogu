"use client";

import { useState } from "react";
import toast from "react-hot-toast";
import { useMutation } from "@tanstack/react-query";
import { authApi } from "@/lib/api";
import { useAuthStore } from "@/store/auth";

export default function SettingsPage() {
  const { user, updateUser } = useAuthStore();
  const [form, setForm] = useState({
    full_name: user?.full_name || "",
    company_name: user?.company_name || "",
  });

  const { mutate: saveProfile, isPending } = useMutation({
    mutationFn: () => authApi.updateProfile(form),
    onSuccess: (res) => {
      updateUser(res.data);
      toast.success("Profile updated");
    },
    onError: () => toast.error("Failed to update profile"),
  });

  return (
    <div className="p-8 max-w-2xl mx-auto animate-fade-in">
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Settings</h1>
        <p className="text-[#8888aa] mt-1">Manage your LifeOS account</p>
      </div>

      {/* Profile */}
      <section className="bg-[#12121a] border border-[#2a2a3d] rounded-2xl p-6 mb-6">
        <h2 className="font-semibold mb-4">Profile</h2>
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1.5">Your Name</label>
            <input
              type="text"
              value={form.full_name}
              onChange={(e) => setForm({ ...form, full_name: e.target.value })}
              className="w-full bg-[#1a1a27] border border-[#2a2a3d] rounded-lg px-4 py-3 text-[#f0f0ff] focus:outline-none focus:border-[#6366f1]"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1.5">Company Name</label>
            <input
              type="text"
              value={form.company_name}
              onChange={(e) => setForm({ ...form, company_name: e.target.value })}
              className="w-full bg-[#1a1a27] border border-[#2a2a3d] rounded-lg px-4 py-3 text-[#f0f0ff] focus:outline-none focus:border-[#6366f1]"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1.5">Email</label>
            <input
              type="email"
              value={user?.email || ""}
              disabled
              className="w-full bg-[#0a0a0f] border border-[#2a2a3d] rounded-lg px-4 py-3 text-[#8888aa] cursor-not-allowed"
            />
          </div>
          <button
            onClick={() => saveProfile()}
            disabled={isPending}
            className="bg-[#6366f1] hover:bg-[#818cf8] disabled:opacity-50 text-white px-6 py-2.5 rounded-lg font-medium transition-colors"
          >
            {isPending ? "Saving..." : "Save Changes"}
          </button>
        </div>
      </section>

      {/* API Keys */}
      <section className="bg-[#12121a] border border-[#2a2a3d] rounded-2xl p-6 mb-6">
        <h2 className="font-semibold mb-2">AI Configuration</h2>
        <p className="text-[#8888aa] text-sm mb-4">
          Your agents are powered by Claude. Configure API keys in your server&apos;s{" "}
          <code className="bg-[#1a1a27] px-1 rounded text-xs">.env</code> file.
        </p>
        <div className="bg-[#1a1a27] rounded-lg p-4 font-mono text-sm text-[#8888aa]">
          <div>ANTHROPIC_API_KEY=sk-ant-...</div>
          <div className="mt-1">PLAID_CLIENT_ID=...</div>
          <div className="mt-1">GOOGLE_CLIENT_ID=...</div>
        </div>
      </section>

      {/* Danger Zone */}
      <section className="bg-[#12121a] border border-red-900/30 rounded-2xl p-6">
        <h2 className="font-semibold text-red-400 mb-2">Danger Zone</h2>
        <p className="text-[#8888aa] text-sm mb-4">
          Deleting your account will permanently remove all agents, conversations, and data.
        </p>
        <button className="bg-red-900/20 hover:bg-red-900/40 text-red-400 border border-red-900/40 px-4 py-2 rounded-lg text-sm transition-colors">
          Delete Account
        </button>
      </section>
    </div>
  );
}
