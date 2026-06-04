window.tailwind = window.tailwind || {};

window.tailwind.config = {
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        "on-tertiary-fixed": "#3c0800",
        "primary-fixed": "#dde1ff",
        "inverse-on-surface": "#edf0ff",
        "on-error-container": "#93000a",
        "error": "#ba1a1a",
        "tertiary-fixed-dim": "#ffb4a1",
        "background": "#f9f9ff",
        "surface-dim": "#d3daef",
        "on-background": "#141b2b",
        "surface-variant": "#dce2f7",
        "on-primary-fixed-variant": "#0038b6",
        "primary-fixed-dim": "#b7c4ff",
        "on-error": "#ffffff",
        "on-primary-container": "#dfe3ff",
        "secondary-fixed-dim": "#c0c7d3",
        "surface-container-lowest": "#ffffff",
        "on-secondary-fixed-variant": "#404751",
        "surface-container": "#e9edff",
        "inverse-primary": "#b7c4ff",
        "secondary": "#585f6a",
        "surface": "#f9f9ff",
        "surface-container-low": "#f1f3ff",
        "on-tertiary": "#ffffff",
        "primary": "#003ec7",
        "outline": "#737688",
        "inverse-surface": "#293040",
        "tertiary": "#952200",
        "on-surface": "#141b2b",
        "secondary-container": "#dce3f0",
        "error-container": "#ffdad6",
        "tertiary-fixed": "#ffdbd2",
        "outline-variant": "#c3c5d9",
        "on-tertiary-container": "#ffddd5",
        "on-secondary-fixed": "#151c25",
        "on-secondary-container": "#5e6570",
        "secondary-fixed": "#dce3f0",
        "tertiary-container": "#bf3003",
        "on-secondary": "#ffffff",
        "surface-container-highest": "#dce2f7",
        "surface-bright": "#f9f9ff",
        "surface-container-high": "#e1e8fd",
        "on-tertiary-fixed-variant": "#891e00",
        "on-primary-fixed": "#001452",
        "primary-container": "#0052ff",
        "surface-tint": "#004ced",
        "on-primary": "#ffffff",
        "on-surface-variant": "#434656"
      },
      borderRadius: {
        "DEFAULT": "0.25rem",
        "lg": "0.5rem",
        "xl": "0.75rem",
        "full": "9999px"
      },
      spacing: {
        "sm": "12px",
        "xs": "4px",
        "base": "8px",
        "lg": "48px",
        "md": "24px",
        "xl": "80px",
        "gutter": "24px",
        "container-max": "1200px"
      },
      fontFamily: {
        "body-lg": ["Inter"],
        "headline-xl": ["Plus Jakarta Sans"],
        "headline-md": ["Plus Jakarta Sans"],
        "label-sm": ["Inter"],
        "headline-lg": ["Plus Jakarta Sans"],
        "label-md": ["Inter"],
        "headline-lg-mobile": ["Plus Jakarta Sans"],
        "body-md": ["Inter"]
      },
      fontSize: {
        "body-lg": ["18px", { "lineHeight": "1.6", "fontWeight": "400" }],
        "headline-xl": ["48px", { "lineHeight": "1.2", "letterSpacing": "-0.02em", "fontWeight": "700" }],
        "headline-md": ["24px", { "lineHeight": "1.3", "fontWeight": "600" }],
        "label-sm": ["12px", { "lineHeight": "1.2", "fontWeight": "600" }],
        "headline-lg": ["32px", { "lineHeight": "1.25", "letterSpacing": "-0.01em", "fontWeight": "700" }],
        "label-md": ["14px", { "lineHeight": "1.4", "letterSpacing": "0.01em", "fontWeight": "500" }],
        "headline-lg-mobile": ["28px", { "lineHeight": "1.3", "fontWeight": "700" }],
        "body-md": ["16px", { "lineHeight": "1.5", "fontWeight": "400" }]
      }
    }
  }
};