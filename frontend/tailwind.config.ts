import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        corridor: {
          green: "#2D6A4F",
          gold: "#D4AF37",
          orange: "#E76F51",
          brown: "#8B4513",
          cream: "#F4E9D7",
          dark: "#1B263B",
        },
      },
      fontFamily: {
        sans: ["var(--font-inter)"],
        display: ["var(--font-space-grotesk)"],
      },
    },
  },
  plugins: [],
};
export default config;
