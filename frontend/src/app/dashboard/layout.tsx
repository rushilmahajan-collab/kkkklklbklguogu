"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useAuthStore } from "@/store/auth";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";

const NAV_ITEMS = [
  { href: "/dashboard", label: "Dashboard", emoji: "🏠" },
  { href: "/dashboard/org-chart", label: "Org Chart", emoji: "🗂️" },
  { href: "/dashboard/integrations", label: "Integrations", emoji: "🔌" },
  { href: "/dashboard/settings", label: "Settings", emoji: "⚙️" },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const { isAuthenticated, user, logout } = useAuthStore();

  useEffect(() => {
    if (!isAuthenticated) {
      router.push("/login");
    }
  }, [isAuthenticated, router]);

  if (!isAuthenticated) return null;

  return (
    <div className="flex h-screen bg-[#0a0a0f] overflow-hidden">
      {/* Sidebar */}
      <aside className="w-64 flex-shrink-0 bg-[#12121a] border-r border-[#2a2a3d] flex flex-col">
        {/* Logo */}
        <div className="px-6 py-5 border-b border-[#2a2a3d]">
          <Link href="/dashboard" className="flex items-center gap-2">
            <span className="text-2xl">🏢</span>
            <div>
              <div className="font-bold text-sm">LifeOS</div>
              <div className="text-[#8888aa] text-xs truncate max-w-[140px]">
                {user?.company_name || "My Life Company"}
              </div>
            </div>
          </Link>
        </div>

        {/* Nav */}
        <nav className="flex-1 px-3 py-4 space-y-1">
          {NAV_ITEMS.map((item) => {
            const isActive =
              item.href === "/dashboard"
                ? pathname === "/dashboard"
                : pathname.startsWith(item.href);
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors",
                  isActive
                    ? "bg-[#6366f1]/20 text-[#818cf8] font-medium"
                    : "text-[#8888aa] hover:text-[#f0f0ff] hover:bg-[#1a1a27]"
                )}
              >
                <span>{item.emoji}</span>
                {item.label}
              </Link>
            );
          })}
        </nav>

        {/* User */}
        <div className="px-4 py-4 border-t border-[#2a2a3d]">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-[#6366f1] flex items-center justify-center text-sm font-bold">
              {user?.full_name?.[0] || user?.email?.[0] || "U"}
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-sm font-medium truncate">
                {user?.full_name || "User"}
              </div>
              <div className="text-xs text-[#8888aa] truncate">{user?.email}</div>
            </div>
            <button
              onClick={() => { logout(); router.push("/"); }}
              className="text-[#8888aa] hover:text-[#f0f0ff] text-xs"
              title="Sign out"
            >
              ↗
            </button>
          </div>
        </div>
      </aside>

      {/* Main */}
      <main className="flex-1 overflow-auto">{children}</main>
    </div>
  );
}
