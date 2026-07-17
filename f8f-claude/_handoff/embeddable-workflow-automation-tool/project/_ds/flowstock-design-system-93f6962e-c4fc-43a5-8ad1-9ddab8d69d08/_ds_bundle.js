/* @ds-bundle: {"format":4,"namespace":"FlowStockDesignSystem_93f696","components":[{"name":"Badge","sourcePath":"components/core/Badge.jsx"},{"name":"Button","sourcePath":"components/core/Button.jsx"},{"name":"Card","sourcePath":"components/core/Card.jsx"},{"name":"CardHeader","sourcePath":"components/core/Card.jsx"},{"name":"CardTitle","sourcePath":"components/core/Card.jsx"},{"name":"CardDescription","sourcePath":"components/core/Card.jsx"},{"name":"CardContent","sourcePath":"components/core/Card.jsx"},{"name":"CardFooter","sourcePath":"components/core/Card.jsx"},{"name":"Accordion","sourcePath":"components/data-display/Accordion.jsx"},{"name":"Avatar","sourcePath":"components/data-display/Avatar.jsx"},{"name":"Separator","sourcePath":"components/data-display/Separator.jsx"},{"name":"InventoryItemCard","sourcePath":"components/domain/InventoryItemCard.jsx"},{"name":"KanbanCard","sourcePath":"components/domain/KanbanCard.jsx"},{"name":"KanbanColumn","sourcePath":"components/domain/KanbanColumn.jsx"},{"name":"MetricCard","sourcePath":"components/domain/MetricCard.jsx"},{"name":"PriorityIcon","sourcePath":"components/domain/PriorityIcon.jsx"},{"name":"StatusBadge","sourcePath":"components/domain/StatusBadge.jsx"},{"name":"Alert","sourcePath":"components/feedback/Alert.jsx"},{"name":"Progress","sourcePath":"components/feedback/Progress.jsx"},{"name":"Skeleton","sourcePath":"components/feedback/Skeleton.jsx"},{"name":"Checkbox","sourcePath":"components/forms/Checkbox.jsx"},{"name":"Input","sourcePath":"components/forms/Input.jsx"},{"name":"Label","sourcePath":"components/forms/Label.jsx"},{"name":"RadioGroup","sourcePath":"components/forms/RadioGroup.jsx"},{"name":"Select","sourcePath":"components/forms/Select.jsx"},{"name":"Textarea","sourcePath":"components/forms/Textarea.jsx"},{"name":"Tabs","sourcePath":"components/navigation/Tabs.jsx"},{"name":"Dialog","sourcePath":"components/overlays/Dialog.jsx"},{"name":"DialogHeader","sourcePath":"components/overlays/Dialog.jsx"},{"name":"DialogTitle","sourcePath":"components/overlays/Dialog.jsx"},{"name":"DialogDescription","sourcePath":"components/overlays/Dialog.jsx"},{"name":"Popover","sourcePath":"components/overlays/Popover.jsx"},{"name":"Sheet","sourcePath":"components/overlays/Sheet.jsx"},{"name":"SheetHeader","sourcePath":"components/overlays/Sheet.jsx"},{"name":"SheetTitle","sourcePath":"components/overlays/Sheet.jsx"},{"name":"SheetDescription","sourcePath":"components/overlays/Sheet.jsx"},{"name":"Tooltip","sourcePath":"components/overlays/Tooltip.jsx"}],"sourceHashes":{"components/core/Badge.jsx":"9669d6031c5f","components/core/Button.jsx":"05760a842163","components/core/Card.jsx":"5e058e793a9c","components/data-display/Accordion.jsx":"5335e7e67a85","components/data-display/Avatar.jsx":"7390acadafa2","components/data-display/Separator.jsx":"2d025478098c","components/domain/InventoryItemCard.jsx":"770cd603c608","components/domain/KanbanCard.jsx":"d9fe8718e250","components/domain/KanbanColumn.jsx":"a6bb12615146","components/domain/MetricCard.jsx":"f3c83843cdbe","components/domain/PriorityIcon.jsx":"3f4d0e6a46de","components/domain/StatusBadge.jsx":"8ce6eae3dc74","components/feedback/Alert.jsx":"ff4447e4f4ed","components/feedback/Progress.jsx":"ea4eb8c1262e","components/feedback/Skeleton.jsx":"d17e29ae47bc","components/forms/Checkbox.jsx":"084919b12fca","components/forms/Input.jsx":"e8ab10e07189","components/forms/Label.jsx":"dc7a9860bec9","components/forms/RadioGroup.jsx":"94420195f34e","components/forms/Select.jsx":"cac541523e57","components/forms/Textarea.jsx":"0c9f1b0b7c0b","components/navigation/Tabs.jsx":"d10e8813440e","components/overlays/Dialog.jsx":"e512d28308d4","components/overlays/Popover.jsx":"331b500c1eac","components/overlays/Sheet.jsx":"b4f6d7862c30","components/overlays/Tooltip.jsx":"207a1809166d","ui_kits/flowstock/Sidebar.jsx":"6bec27a0729c","ui_kits/flowstock/data.js":"e8fae2660e92","ui_kits/flowstock/icons.js":"963b61139d32","ui_kits/flowstock/screens/DashboardScreen.jsx":"b62d7061c748"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.FlowStockDesignSystem_93f696 = window.FlowStockDesignSystem_93f696 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/core/Badge.jsx
try { (() => {
const variants = {
  default: {
    background: 'var(--primary)',
    color: 'var(--primary-foreground)'
  },
  secondary: {
    background: 'var(--secondary)',
    color: 'var(--secondary-foreground)'
  },
  destructive: {
    background: 'var(--destructive)',
    color: 'var(--destructive-foreground)'
  },
  outline: {
    background: 'transparent',
    color: 'var(--foreground)',
    border: '1px solid var(--border)'
  }
};
function Badge({
  variant = 'default',
  style,
  children,
  ...props
}) {
  const v = variants[variant] || variants.default;
  return React.createElement('span', {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      borderRadius: 'var(--radius-md)',
      padding: '2px 10px',
      fontSize: '12px',
      fontWeight: 600,
      fontFamily: 'var(--font-sans)',
      whiteSpace: 'nowrap',
      ...v,
      ...style
    },
    ...props
  }, children);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Badge.jsx", error: String((e && e.message) || e) }); }

// components/core/Button.jsx
try { (() => {
const variants = {
  default: 'background:var(--primary);color:var(--primary-foreground);box-shadow:var(--shadow-sm);',
  destructive: 'background:var(--destructive);color:var(--destructive-foreground);box-shadow:var(--shadow-sm);',
  outline: 'background:transparent;color:var(--foreground);border:1px solid var(--input);box-shadow:var(--shadow-sm);',
  secondary: 'background:var(--secondary);color:var(--secondary-foreground);box-shadow:var(--shadow-sm);',
  ghost: 'background:transparent;color:var(--foreground);',
  link: 'background:transparent;color:var(--primary);text-decoration:underline;text-underline-offset:4px;',
  gradient: 'background:var(--gradient-brand-soft);color:#fff;box-shadow:var(--shadow-sm);'
};
const sizes = {
  default: 'height:36px;padding:0 16px;font-size:14px;',
  sm: 'height:32px;padding:0 12px;font-size:12px;',
  lg: 'height:40px;padding:0 32px;font-size:14px;',
  icon: 'height:36px;width:36px;padding:0;'
};
function Button({
  variant = 'default',
  size = 'default',
  disabled,
  style,
  children,
  ...props
}) {
  const [hover, setHover] = React.useState(false);
  const base = 'display:inline-flex;align-items:center;justify-content:center;gap:8px;white-space:nowrap;border-radius:var(--radius-md);font-weight:500;font-family:var(--font-sans);transition:filter var(--duration-fast) var(--ease-standard),opacity var(--duration-fast);cursor:pointer;border:none;';
  const opacity = disabled ? 'opacity:0.5;pointer-events:none;' : '';
  const hoverFilter = hover && !disabled ? 'filter:brightness(0.94);' : '';
  const cssText = base + variants[variant] + sizes[size] + opacity + hoverFilter;
  return React.createElement('button', {
    disabled,
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      ...styleStringToObject(cssText),
      ...style
    },
    ...props
  }, children);
}
function styleStringToObject(css) {
  const obj = {};
  css.split(';').forEach(rule => {
    const idx = rule.indexOf(':');
    if (idx < 0) return;
    const k = rule.slice(0, idx).trim();
    const v = rule.slice(idx + 1).trim();
    if (!k) return;
    const camel = k.replace(/-([a-z])/g, (_, c) => c.toUpperCase());
    obj[camel] = v;
  });
  return obj;
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Button.jsx", error: String((e && e.message) || e) }); }

// components/core/Card.jsx
try { (() => {
function Card({
  style,
  children,
  ...props
}) {
  return React.createElement('div', {
    style: {
      background: 'var(--card)',
      borderRadius: 'var(--radius-xl)',
      border: 'none',
      boxShadow: 'var(--shadow-md)',
      color: 'var(--card-foreground)',
      ...style
    },
    ...props
  }, children);
}
function CardHeader({
  style,
  children,
  ...props
}) {
  return React.createElement('div', {
    style: {
      padding: '20px 20px 8px',
      display: 'flex',
      flexDirection: 'column',
      gap: '4px',
      ...style
    },
    ...props
  }, children);
}
function CardTitle({
  style,
  children,
  ...props
}) {
  return React.createElement('div', {
    style: {
      fontWeight: 700,
      fontSize: '16px',
      lineHeight: 1.2,
      ...style
    },
    ...props
  }, children);
}
function CardDescription({
  style,
  children,
  ...props
}) {
  return React.createElement('div', {
    style: {
      fontSize: '13px',
      color: 'var(--muted-foreground)',
      ...style
    },
    ...props
  }, children);
}
function CardContent({
  style,
  children,
  ...props
}) {
  return React.createElement('div', {
    style: {
      padding: '20px',
      paddingTop: 0,
      ...style
    },
    ...props
  }, children);
}
function CardFooter({
  style,
  children,
  ...props
}) {
  return React.createElement('div', {
    style: {
      padding: '20px',
      paddingTop: 0,
      display: 'flex',
      alignItems: 'center',
      ...style
    },
    ...props
  }, children);
}
Object.assign(__ds_scope, { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Card.jsx", error: String((e && e.message) || e) }); }

// components/data-display/Accordion.jsx
try { (() => {
function Accordion({
  items = []
}) {
  const [openIdx, setOpenIdx] = React.useState(null);
  return React.createElement('div', {
    style: {
      display: 'flex',
      flexDirection: 'column'
    }
  }, items.map((it, i) => React.createElement('div', {
    key: i,
    style: {
      borderBottom: '1px solid var(--border)'
    }
  }, React.createElement('button', {
    onClick: () => setOpenIdx(openIdx === i ? null : i),
    style: {
      width: '100%',
      textAlign: 'left',
      padding: '12px 0',
      background: 'none',
      border: 'none',
      fontWeight: 600,
      fontSize: 14,
      cursor: 'pointer',
      color: 'var(--foreground)',
      fontFamily: 'var(--font-sans)'
    }
  }, it.title), openIdx === i && React.createElement('div', {
    style: {
      paddingBottom: 12,
      fontSize: 13,
      color: 'var(--muted-foreground)'
    }
  }, it.content))));
}
Object.assign(__ds_scope, { Accordion });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data-display/Accordion.jsx", error: String((e && e.message) || e) }); }

// components/data-display/Avatar.jsx
try { (() => {
function Avatar({
  initial,
  size = 32,
  style
}) {
  return React.createElement('div', {
    style: {
      width: size,
      height: size,
      borderRadius: '50%',
      background: 'var(--gradient-brand-soft)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      color: '#fff',
      fontWeight: 700,
      fontSize: size * 0.4,
      boxShadow: '0 0 0 2px #fff',
      ...style
    }
  }, (initial || '?').slice(0, 1).toUpperCase());
}
Object.assign(__ds_scope, { Avatar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data-display/Avatar.jsx", error: String((e && e.message) || e) }); }

// components/data-display/Separator.jsx
try { (() => {
function Separator({
  style
}) {
  return React.createElement('div', {
    style: {
      height: 1,
      width: '100%',
      background: 'var(--border)',
      ...style
    }
  });
}
Object.assign(__ds_scope, { Separator });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data-display/Separator.jsx", error: String((e && e.message) || e) }); }

// components/domain/InventoryItemCard.jsx
try { (() => {
const CAT = {
  electronics: {
    bg: 'var(--blue-100)',
    fg: '#1e40af'
  },
  spare_parts: {
    bg: 'var(--red-100)',
    fg: 'var(--red-700)'
  },
  consumables: {
    bg: 'var(--yellow-100)',
    fg: 'var(--yellow-700)'
  },
  tools: {
    bg: 'var(--slate-100)',
    fg: 'var(--slate-700)'
  },
  other: {
    bg: 'var(--slate-100)',
    fg: 'var(--slate-700)'
  }
};
function InventoryItemCard({
  name,
  sku,
  category = 'other',
  stock = 0,
  minStock = 10,
  price = 0
}) {
  const low = stock <= minStock;
  const c = CAT[category] || CAT.other;
  return React.createElement('div', {
    style: {
      background: 'rgba(255,255,255,0.8)',
      borderRadius: 'var(--radius-xl)',
      boxShadow: 'var(--shadow-md)',
      padding: 20,
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, React.createElement('div', {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'flex-start',
      gap: 8
    }
  }, React.createElement('div', {
    style: {
      fontWeight: 700,
      fontSize: 16,
      color: 'var(--slate-800)'
    }
  }, name), React.createElement('span', {
    style: {
      fontSize: 11,
      fontWeight: 700,
      padding: '2px 8px',
      borderRadius: 6,
      whiteSpace: 'nowrap',
      background: low ? 'var(--red-600)' : 'var(--muted)',
      color: low ? '#fff' : 'var(--foreground)'
    }
  }, stock, ' in stock')), React.createElement('div', {
    style: {
      fontSize: 12,
      color: 'var(--muted-foreground)',
      fontFamily: 'var(--font-mono)'
    }
  }, sku), React.createElement('span', {
    style: {
      fontSize: 11,
      fontWeight: 600,
      padding: '2px 8px',
      borderRadius: 6,
      background: c.bg,
      color: c.fg,
      alignSelf: 'flex-start'
    }
  }, category), React.createElement('div', {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      borderTop: '1px solid var(--border)',
      paddingTop: 12
    }
  }, React.createElement('span', {
    style: {
      fontWeight: 700,
      fontSize: 18
    }
  }, '$' + price.toFixed(2)), React.createElement('button', {
    style: {
      fontSize: 13,
      fontWeight: 600,
      padding: '6px 14px',
      borderRadius: 'var(--radius-md)',
      background: 'var(--primary)',
      color: '#fff',
      border: 'none',
      cursor: 'pointer'
    }
  }, 'Edit')));
}
Object.assign(__ds_scope, { InventoryItemCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/domain/InventoryItemCard.jsx", error: String((e && e.message) || e) }); }

// components/domain/KanbanCard.jsx
try { (() => {
const PRIORITY_BORDER = {
  low: 'var(--green-400)',
  medium: '#facc15',
  high: 'var(--orange-500)',
  urgent: 'var(--red-400)'
};
const DEVICE_COLOR = {
  Laptop: {
    bg: 'var(--red-100)',
    fg: 'var(--red-700)'
  },
  Phone: {
    bg: 'var(--blue-100)',
    fg: '#1d4ed8'
  },
  Tablet: {
    bg: 'var(--purple-100)',
    fg: 'var(--purple-700)'
  },
  Desktop: {
    bg: 'var(--green-100)',
    fg: 'var(--green-700)'
  },
  Other: {
    bg: 'var(--orange-100)',
    fg: 'var(--orange-700)'
  }
};
function KanbanCard({
  title,
  customerName,
  deviceType = 'Other',
  tags = [],
  priority = 'medium',
  assigneeInitial,
  onClick
}) {
  const dc = DEVICE_COLOR[deviceType] || DEVICE_COLOR.Other;
  return React.createElement('div', {
    onClick,
    style: {
      background: '#fff',
      borderRadius: 8,
      padding: 16,
      marginBottom: 12,
      boxShadow: 'var(--shadow-md)',
      borderLeft: '4px solid ' + PRIORITY_BORDER[priority],
      cursor: 'pointer'
    }
  }, React.createElement('div', {
    style: {
      fontWeight: 600,
      color: 'var(--slate-800)',
      marginBottom: 6
    }
  }, title), customerName && React.createElement('div', {
    style: {
      fontSize: 13,
      color: 'var(--muted-foreground)',
      marginBottom: 8
    }
  }, customerName), React.createElement('div', {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: 6,
      marginBottom: 12
    }
  }, React.createElement('span', {
    style: {
      fontSize: 11,
      fontWeight: 600,
      padding: '2px 8px',
      borderRadius: 6,
      background: dc.bg,
      color: dc.fg
    }
  }, deviceType), tags.map(t => React.createElement('span', {
    key: t,
    style: {
      fontSize: 11,
      padding: '2px 8px',
      borderRadius: 6,
      background: 'var(--muted)',
      color: 'var(--muted-foreground)'
    }
  }, t))), React.createElement('div', {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center'
    }
  }, React.createElement('span', {
    style: {
      fontSize: 11,
      color: 'var(--muted-foreground)'
    }
  }, '🔧 Parts: 2'), assigneeInitial && React.createElement('div', {
    style: {
      width: 24,
      height: 24,
      borderRadius: '50%',
      background: 'var(--gradient-brand-soft)',
      color: '#fff',
      fontSize: 11,
      fontWeight: 700,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, assigneeInitial)));
}
Object.assign(__ds_scope, { KanbanCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/domain/KanbanCard.jsx", error: String((e && e.message) || e) }); }

// components/domain/KanbanColumn.jsx
try { (() => {
function KanbanColumn({
  title,
  count,
  headerColor = 'var(--slate-200)',
  children
}) {
  return React.createElement('div', {
    style: {
      display: 'flex',
      flexDirection: 'column',
      background: 'rgba(241,245,249,0.7)',
      borderRadius: 'var(--radius-lg)',
      minHeight: 200
    }
  }, React.createElement('div', {
    style: {
      padding: 14,
      borderTopLeftRadius: 'var(--radius-lg)',
      borderTopRightRadius: 'var(--radius-lg)',
      background: headerColor,
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center'
    }
  }, React.createElement('span', {
    style: {
      fontWeight: 700,
      color: 'var(--slate-800)'
    }
  }, title), React.createElement('span', {
    style: {
      fontSize: 13,
      fontWeight: 600,
      color: 'var(--slate-600)',
      background: 'rgba(255,255,255,0.5)',
      borderRadius: 'var(--radius-full)',
      padding: '1px 8px'
    }
  }, count)), React.createElement('div', {
    style: {
      flex: 1,
      padding: 12
    }
  }, children));
}
Object.assign(__ds_scope, { KanbanColumn });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/domain/KanbanColumn.jsx", error: String((e && e.message) || e) }); }

// components/domain/MetricCard.jsx
try { (() => {
const GRADIENTS = {
  blue: 'linear-gradient(to bottom right,var(--blue-500),var(--blue-600))',
  green: 'linear-gradient(to bottom right,var(--green-500),var(--green-600))',
  purple: 'linear-gradient(to bottom right,var(--purple-500),var(--purple-600))',
  red: 'linear-gradient(to bottom right,var(--red-500),var(--red-600))'
};
function MetricCard({
  title,
  value,
  sub,
  color = 'blue',
  iconGlyph = '●'
}) {
  return React.createElement('div', {
    style: {
      background: 'var(--card)',
      borderRadius: 'var(--radius-xl)',
      boxShadow: 'var(--shadow-md)',
      padding: 20
    }
  }, React.createElement('div', {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'flex-start'
    }
  }, React.createElement('div', null, React.createElement('div', {
    style: {
      fontSize: 13,
      color: 'var(--muted-foreground)',
      fontWeight: 500
    }
  }, title), React.createElement('div', {
    style: {
      fontSize: 28,
      fontWeight: 700,
      color: 'var(--foreground)',
      marginTop: 4
    }
  }, value), sub && React.createElement('div', {
    style: {
      fontSize: 11,
      color: 'var(--slate-400)',
      marginTop: 4
    }
  }, sub)), React.createElement('div', {
    style: {
      width: 40,
      height: 40,
      borderRadius: 'var(--radius-lg)',
      background: GRADIENTS[color] || GRADIENTS.blue,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      color: '#fff',
      fontSize: 16
    }
  }, iconGlyph)));
}
Object.assign(__ds_scope, { MetricCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/domain/MetricCard.jsx", error: String((e && e.message) || e) }); }

// components/domain/PriorityIcon.jsx
try { (() => {
const PRI = {
  low: {
    color: 'var(--priority-low)',
    glyph: '↓'
  },
  medium: {
    color: 'var(--priority-medium)',
    glyph: '↑'
  },
  high: {
    color: 'var(--priority-high)',
    glyph: '⇈'
  },
  urgent: {
    color: 'var(--priority-urgent)',
    glyph: '⇊'
  }
};
function PriorityIcon({
  priority = 'medium',
  style
}) {
  const p = PRI[priority] || PRI.medium;
  return React.createElement('span', {
    title: priority,
    style: {
      color: p.color,
      fontWeight: 700,
      fontSize: 14,
      ...style
    }
  }, p.glyph);
}
Object.assign(__ds_scope, { PriorityIcon });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/domain/PriorityIcon.jsx", error: String((e && e.message) || e) }); }

// components/domain/StatusBadge.jsx
try { (() => {
const STATUS = {
  intake: {
    bg: '--status-intake-bg',
    fg: '--status-intake-fg',
    label: 'Intake'
  },
  diagnosis: {
    bg: '--status-diagnosis-bg',
    fg: '--status-diagnosis-fg',
    label: 'Diagnosis'
  },
  waiting_parts: {
    bg: '--status-waiting-bg',
    fg: '--status-waiting-fg',
    label: 'Waiting Parts'
  },
  in_repair: {
    bg: '--status-inrepair-bg',
    fg: '--status-inrepair-fg',
    label: 'In Repair'
  },
  quality_check: {
    bg: '--status-qc-bg',
    fg: '--status-qc-fg',
    label: 'Quality Check'
  },
  ready: {
    bg: '--status-ready-bg',
    fg: '--status-ready-fg',
    label: 'Ready'
  },
  collected: {
    bg: '--status-collected-bg',
    fg: '--status-collected-fg',
    label: 'Collected'
  },
  cancelled: {
    bg: '--status-cancelled-bg',
    fg: '--status-cancelled-fg',
    label: 'Cancelled'
  }
};
function StatusBadge({
  status = 'intake',
  style
}) {
  const s = STATUS[status] || STATUS.intake;
  return React.createElement('span', {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      padding: '3px 10px',
      borderRadius: 'var(--radius-md)',
      fontSize: 12,
      fontWeight: 600,
      background: 'var(' + s.bg + ')',
      color: 'var(' + s.fg + ')',
      fontFamily: 'var(--font-sans)',
      whiteSpace: 'nowrap',
      ...style
    }
  }, s.label);
}
Object.assign(__ds_scope, { StatusBadge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/domain/StatusBadge.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Alert.jsx
try { (() => {
const kinds = {
  info: {
    bg: 'var(--blue-50)',
    fg: 'var(--blue-700)',
    border: 'var(--blue-200)'
  },
  warning: {
    bg: 'var(--yellow-50)',
    fg: 'var(--yellow-700)',
    border: 'var(--yellow-100)'
  },
  success: {
    bg: 'var(--green-100)',
    fg: 'var(--green-700)',
    border: 'var(--green-100)'
  },
  destructive: {
    bg: 'var(--red-50)',
    fg: 'var(--red-700)',
    border: 'var(--red-100)'
  }
};
function Alert({
  kind = 'info',
  title,
  children,
  style
}) {
  const k = kinds[kind] || kinds.info;
  return React.createElement('div', {
    style: {
      background: k.bg,
      color: k.fg,
      border: '1px solid ' + k.border,
      borderRadius: 'var(--radius-lg)',
      padding: '12px 14px',
      fontSize: 13,
      ...style
    }
  }, title && React.createElement('div', {
    style: {
      fontWeight: 700,
      marginBottom: 2
    }
  }, title), children);
}
Object.assign(__ds_scope, { Alert });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Alert.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Progress.jsx
try { (() => {
function Progress({
  value = 0,
  style
}) {
  return React.createElement('div', {
    style: {
      width: '100%',
      height: 8,
      borderRadius: 'var(--radius-full)',
      background: 'var(--muted)',
      overflow: 'hidden',
      ...style
    }
  }, React.createElement('div', {
    style: {
      width: Math.min(100, Math.max(0, value)) + '%',
      height: '100%',
      background: 'var(--gradient-brand-soft)',
      borderRadius: 'var(--radius-full)',
      transition: 'width var(--duration-normal) var(--ease-standard)'
    }
  }));
}
Object.assign(__ds_scope, { Progress });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Progress.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Skeleton.jsx
try { (() => {
function Skeleton({
  style
}) {
  return React.createElement('div', {
    style: {
      background: 'var(--slate-200)',
      borderRadius: 'var(--radius-lg)',
      animation: 'flowstock-pulse 1.5s ease-in-out infinite',
      ...style
    }
  });
}
Object.assign(__ds_scope, { Skeleton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Skeleton.jsx", error: String((e && e.message) || e) }); }

// components/forms/Checkbox.jsx
try { (() => {
function Checkbox({
  checked,
  onCheckedChange,
  style,
  ...props
}) {
  return React.createElement('input', {
    type: 'checkbox',
    checked: !!checked,
    onChange: e => onCheckedChange && onCheckedChange(e.target.checked),
    style: {
      width: 16,
      height: 16,
      borderRadius: '4px',
      accentColor: 'var(--primary)',
      ...style
    },
    ...props
  });
}
Object.assign(__ds_scope, { Checkbox });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Checkbox.jsx", error: String((e && e.message) || e) }); }

// components/forms/Input.jsx
try { (() => {
function Input({
  style,
  ...props
}) {
  return React.createElement('input', {
    style: {
      display: 'flex',
      height: '36px',
      width: '100%',
      borderRadius: 'var(--radius-md)',
      border: '1px solid var(--input)',
      background: 'transparent',
      padding: '0 12px',
      fontSize: '14px',
      fontFamily: 'var(--font-sans)',
      color: 'var(--foreground)',
      boxShadow: 'var(--shadow-sm)',
      outline: 'none',
      ...style
    },
    ...props
  });
}
Object.assign(__ds_scope, { Input });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Input.jsx", error: String((e && e.message) || e) }); }

// components/forms/Label.jsx
try { (() => {
function Label({
  style,
  children,
  ...props
}) {
  return React.createElement('label', {
    style: {
      fontSize: '14px',
      fontWeight: 500,
      color: 'var(--foreground)',
      display: 'block',
      marginBottom: '6px',
      ...style
    },
    ...props
  }, children);
}
Object.assign(__ds_scope, { Label });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Label.jsx", error: String((e && e.message) || e) }); }

// components/forms/RadioGroup.jsx
try { (() => {
function RadioGroup({
  value,
  onValueChange,
  options = [],
  name = 'radio-group',
  style
}) {
  return React.createElement('div', {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8,
      ...style
    }
  }, options.map(o => React.createElement('label', {
    key: o.value,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      fontSize: 14,
      color: 'var(--foreground)',
      cursor: 'pointer'
    }
  }, React.createElement('input', {
    type: 'radio',
    name,
    checked: value === o.value,
    onChange: () => onValueChange && onValueChange(o.value),
    style: {
      accentColor: 'var(--primary)',
      width: 16,
      height: 16
    }
  }), o.label)));
}
Object.assign(__ds_scope, { RadioGroup });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/RadioGroup.jsx", error: String((e && e.message) || e) }); }

// components/forms/Select.jsx
try { (() => {
function Select({
  value,
  onValueChange,
  options = [],
  placeholder,
  style
}) {
  return React.createElement('select', {
    value: value || '',
    onChange: e => onValueChange && onValueChange(e.target.value),
    style: {
      display: 'flex',
      height: '36px',
      width: '100%',
      borderRadius: 'var(--radius-md)',
      border: '1px solid var(--input)',
      background: 'transparent',
      padding: '0 10px',
      fontSize: '14px',
      fontFamily: 'var(--font-sans)',
      color: 'var(--foreground)',
      boxShadow: 'var(--shadow-sm)',
      outline: 'none',
      ...style
    }
  }, [placeholder && React.createElement('option', {
    key: '_ph',
    value: '',
    disabled: true
  }, placeholder), ...options.map(o => React.createElement('option', {
    key: o.value,
    value: o.value
  }, o.label))]);
}
Object.assign(__ds_scope, { Select });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Select.jsx", error: String((e && e.message) || e) }); }

// components/forms/Textarea.jsx
try { (() => {
function Textarea({
  style,
  rows = 3,
  ...props
}) {
  return React.createElement('textarea', {
    rows,
    style: {
      display: 'flex',
      width: '100%',
      minHeight: '60px',
      borderRadius: 'var(--radius-md)',
      border: '1px solid var(--input)',
      background: 'transparent',
      padding: '8px 12px',
      fontSize: '14px',
      fontFamily: 'var(--font-sans)',
      color: 'var(--foreground)',
      boxShadow: 'var(--shadow-sm)',
      outline: 'none',
      resize: 'vertical',
      ...style
    },
    ...props
  });
}
Object.assign(__ds_scope, { Textarea });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Textarea.jsx", error: String((e && e.message) || e) }); }

// components/navigation/Tabs.jsx
try { (() => {
function Tabs({
  value,
  onValueChange,
  tabs = [],
  children
}) {
  return React.createElement('div', null, React.createElement('div', {
    style: {
      display: 'flex',
      gap: 4,
      background: 'var(--muted)',
      padding: 4,
      borderRadius: 'var(--radius-lg)'
    }
  }, tabs.map(t => React.createElement('button', {
    key: t.value,
    onClick: () => onValueChange && onValueChange(t.value),
    style: {
      flex: 1,
      padding: '8px 12px',
      borderRadius: 'var(--radius-md)',
      border: 'none',
      fontSize: 13,
      fontWeight: 600,
      cursor: 'pointer',
      fontFamily: 'var(--font-sans)',
      background: value === t.value ? 'var(--card)' : 'transparent',
      color: value === t.value ? 'var(--foreground)' : 'var(--muted-foreground)',
      boxShadow: value === t.value ? 'var(--shadow-sm)' : 'none'
    }
  }, t.label))), React.createElement('div', {
    style: {
      marginTop: 16
    }
  }, children));
}
Object.assign(__ds_scope, { Tabs });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/Tabs.jsx", error: String((e && e.message) || e) }); }

// components/overlays/Dialog.jsx
try { (() => {
function Dialog({
  open,
  onOpenChange,
  children
}) {
  if (!open) return null;
  return React.createElement('div', {
    style: {
      position: 'fixed',
      inset: 0,
      zIndex: 50,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, React.createElement('div', {
    onClick: () => onOpenChange && onOpenChange(false),
    style: {
      position: 'absolute',
      inset: 0,
      background: 'rgba(0,0,0,0.4)'
    }
  }), React.createElement('div', {
    style: {
      position: 'relative',
      background: 'var(--card)',
      borderRadius: 'var(--radius-xl)',
      boxShadow: 'var(--shadow-xl)',
      padding: 24,
      maxWidth: 480,
      width: '90%',
      maxHeight: '85vh',
      overflowY: 'auto'
    }
  }, children));
}
function DialogHeader({
  children,
  style
}) {
  return React.createElement('div', {
    style: {
      marginBottom: 16,
      ...style
    }
  }, children);
}
function DialogTitle({
  children,
  style
}) {
  return React.createElement('div', {
    style: {
      fontSize: 18,
      fontWeight: 700,
      color: 'var(--foreground)',
      ...style
    }
  }, children);
}
function DialogDescription({
  children,
  style
}) {
  return React.createElement('div', {
    style: {
      fontSize: 13,
      color: 'var(--muted-foreground)',
      marginTop: 4,
      ...style
    }
  }, children);
}
Object.assign(__ds_scope, { Dialog, DialogHeader, DialogTitle, DialogDescription });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/overlays/Dialog.jsx", error: String((e && e.message) || e) }); }

// components/overlays/Popover.jsx
try { (() => {
function Popover({
  trigger,
  children
}) {
  const [open, setOpen] = React.useState(false);
  return React.createElement('div', {
    style: {
      position: 'relative',
      display: 'inline-block'
    }
  }, React.createElement('div', {
    onClick: () => setOpen(o => !o)
  }, trigger), open && React.createElement('div', {
    style: {
      position: 'absolute',
      top: '100%',
      left: 0,
      marginTop: 6,
      background: 'var(--card)',
      border: '1px solid var(--border)',
      borderRadius: 'var(--radius-lg)',
      boxShadow: 'var(--shadow-lg)',
      padding: 12,
      zIndex: 30,
      minWidth: 180
    }
  }, children));
}
Object.assign(__ds_scope, { Popover });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/overlays/Popover.jsx", error: String((e && e.message) || e) }); }

// components/overlays/Sheet.jsx
try { (() => {
function Sheet({
  open,
  onOpenChange,
  children
}) {
  return React.createElement(React.Fragment, null, open && React.createElement('div', {
    onClick: () => onOpenChange && onOpenChange(false),
    style: {
      position: 'fixed',
      inset: 0,
      background: 'rgba(0,0,0,0.4)',
      zIndex: 40
    }
  }), React.createElement('div', {
    style: {
      position: 'fixed',
      top: 0,
      right: 0,
      bottom: 0,
      width: 'min(480px,92vw)',
      background: 'var(--card)',
      boxShadow: 'var(--shadow-xl)',
      zIndex: 41,
      padding: 24,
      overflowY: 'auto',
      transform: open ? 'translateX(0)' : 'translateX(100%)',
      transition: 'transform var(--duration-normal) var(--ease-standard)'
    }
  }, children));
}
function SheetHeader({
  children
}) {
  return React.createElement('div', {
    style: {
      marginBottom: 20
    }
  }, children);
}
function SheetTitle({
  children
}) {
  return React.createElement('div', {
    style: {
      fontSize: 22,
      fontWeight: 700,
      color: 'var(--foreground)'
    }
  }, children);
}
function SheetDescription({
  children
}) {
  return React.createElement('div', {
    style: {
      fontSize: 13,
      color: 'var(--muted-foreground)',
      marginTop: 4
    }
  }, children);
}
Object.assign(__ds_scope, { Sheet, SheetHeader, SheetTitle, SheetDescription });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/overlays/Sheet.jsx", error: String((e && e.message) || e) }); }

// components/overlays/Tooltip.jsx
try { (() => {
function Tooltip({
  label,
  children
}) {
  const [show, setShow] = React.useState(false);
  return React.createElement('span', {
    style: {
      position: 'relative',
      display: 'inline-block'
    },
    onMouseEnter: () => setShow(true),
    onMouseLeave: () => setShow(false)
  }, children, show && React.createElement('span', {
    style: {
      position: 'absolute',
      bottom: '100%',
      left: '50%',
      transform: 'translateX(-50%)',
      marginBottom: 6,
      background: 'var(--slate-900)',
      color: '#fff',
      fontSize: 11,
      padding: '4px 8px',
      borderRadius: 6,
      whiteSpace: 'nowrap',
      zIndex: 50
    }
  }, label));
}
Object.assign(__ds_scope, { Tooltip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/overlays/Tooltip.jsx", error: String((e && e.message) || e) }); }

// ui_kits/flowstock/Sidebar.jsx
try { (() => {
function Sidebar({
  active,
  onNav,
  company,
  onLogout
}) {
  const Icon = window.FSIcon;
  const items = [{
    label: 'Dashboard',
    path: 'dashboard',
    icon: 'layout-dashboard'
  }, {
    label: 'Repairs',
    path: 'kanban',
    icon: 'wrench'
  }, {
    label: 'Inventory',
    path: 'inventory',
    icon: 'package'
  }];
  return /*#__PURE__*/React.createElement("aside", {
    style: {
      width: 240,
      background: 'var(--slate-900)',
      display: 'flex',
      flexDirection: 'column',
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      padding: '16px 20px',
      borderBottom: '1px solid var(--sidebar-border)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 28,
      height: 28,
      borderRadius: 8,
      background: 'var(--blue-500)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "wrench",
    size: 16,
    color: "#fff"
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      color: '#fff',
      fontWeight: 700,
      fontSize: 18
    }
  }, "FlowStock")), company && /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '12px 16px',
      borderBottom: '1px solid var(--sidebar-border)'
    }
  }, /*#__PURE__*/React.createElement("p", {
    style: {
      color: 'var(--sidebar-fg-muted)',
      fontSize: 11,
      textTransform: 'uppercase',
      letterSpacing: '0.05em',
      margin: 0
    }
  }, "Shop"), /*#__PURE__*/React.createElement("p", {
    style: {
      color: '#fff',
      fontWeight: 600,
      fontSize: 14,
      margin: '2px 0 0'
    }
  }, company)), /*#__PURE__*/React.createElement("nav", {
    style: {
      flex: 1,
      padding: '16px 12px',
      display: 'flex',
      flexDirection: 'column',
      gap: 4
    }
  }, items.map(it => {
    const isActive = active === it.path;
    return /*#__PURE__*/React.createElement("button", {
      key: it.path,
      onClick: () => onNav(it.path),
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 12,
        padding: '10px 12px',
        borderRadius: 8,
        border: 'none',
        fontSize: 14,
        fontWeight: 500,
        cursor: 'pointer',
        fontFamily: 'var(--font-sans)',
        textAlign: 'left',
        background: isActive ? 'var(--blue-600)' : 'transparent',
        color: isActive ? '#fff' : 'var(--sidebar-fg-muted)'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: it.icon,
      size: 16,
      color: isActive ? '#fff' : 'var(--sidebar-fg-muted)'
    }), it.label);
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: 16,
      borderTop: '1px solid var(--sidebar-border)'
    }
  }, /*#__PURE__*/React.createElement("button", {
    onClick: onLogout,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      background: 'none',
      border: 'none',
      color: 'var(--sidebar-fg-muted)',
      fontSize: 13,
      cursor: 'pointer',
      fontFamily: 'var(--font-sans)',
      width: '100%'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "log-out",
    size: 14,
    color: "var(--sidebar-fg-muted)"
  }), "Sign out")));
}
window.Sidebar = Sidebar;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/flowstock/Sidebar.jsx", error: String((e && e.message) || e) }); }

// ui_kits/flowstock/data.js
try { (() => {
window.FS_DATA = {
  jobs: [{
    id: '1',
    title: 'iPhone 15 Pro screen replacement',
    customer_name: 'John Smith',
    device_type: 'Phone',
    status: 'in_repair',
    priority: 'urgent',
    tags: ['screen'],
    assignee: 'A',
    created_date: '2026-07-12T10:00:00'
  }, {
    id: '2',
    title: 'Dell XPS 13 battery swap',
    customer_name: 'Mia Rodriguez',
    device_type: 'Laptop',
    status: 'waiting_parts',
    priority: 'medium',
    tags: ['battery'],
    assignee: 'J',
    created_date: '2026-07-11T14:30:00'
  }, {
    id: '3',
    title: 'iPad Air digitizer',
    customer_name: 'Sam Lee',
    device_type: 'Tablet',
    status: 'diagnosis',
    priority: 'low',
    tags: [],
    assignee: 'A',
    created_date: '2026-07-13T09:15:00'
  }, {
    id: '4',
    title: 'Samsung S23 charging port',
    customer_name: 'Priya Patel',
    device_type: 'Phone',
    status: 'quality_check',
    priority: 'high',
    tags: ['port'],
    assignee: 'J',
    created_date: '2026-07-10T11:00:00'
  }, {
    id: '5',
    title: 'MacBook Pro keyboard',
    customer_name: 'Tom Becker',
    device_type: 'Laptop',
    status: 'ready',
    priority: 'medium',
    tags: ['keyboard'],
    assignee: 'A',
    created_date: '2026-07-09T16:00:00'
  }, {
    id: '6',
    title: 'Pixel 8 back glass',
    customer_name: 'Lars Heidtmann',
    device_type: 'Phone',
    status: 'collected',
    priority: 'low',
    tags: ['back glass'],
    assignee: 'J',
    created_date: '2026-07-08T13:00:00'
  }, {
    id: '7',
    title: 'Custom desktop PSU repair',
    customer_name: 'Erin Voss',
    device_type: 'Desktop',
    status: 'intake',
    priority: 'medium',
    tags: [],
    assignee: null,
    created_date: '2026-07-13T17:20:00'
  }],
  inventory: [{
    id: 'i1',
    name: 'iPhone 15 Screen (OEM)',
    sku: 'SCR-IP15-001',
    category: 'spare_parts',
    current_stock: 2,
    min_stock_level: 5,
    sale_price: 129
  }, {
    id: 'i2',
    name: 'USB-C Charging Port',
    sku: 'PRT-USBC-014',
    category: 'spare_parts',
    current_stock: 18,
    min_stock_level: 10,
    sale_price: 14
  }, {
    id: 'i3',
    name: 'Laptop Battery 45Wh',
    sku: 'BAT-45W-002',
    category: 'spare_parts',
    current_stock: 6,
    min_stock_level: 8,
    sale_price: 59
  }, {
    id: 'i4',
    name: 'Isopropyl Alcohol 99%',
    sku: 'CON-IPA-500',
    category: 'consumables',
    current_stock: 24,
    min_stock_level: 10,
    sale_price: 6
  }, {
    id: 'i5',
    name: 'Precision Screwdriver Set',
    sku: 'TL-PSD-012',
    category: 'tools',
    current_stock: 9,
    min_stock_level: 4,
    sale_price: 22
  }, {
    id: 'i6',
    name: 'Diagnostic Software License',
    sku: 'SFT-DIAG-01',
    category: 'software',
    current_stock: 50,
    min_stock_level: 10,
    sale_price: 0
  }]
};
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/flowstock/data.js", error: String((e && e.message) || e) }); }

// ui_kits/flowstock/icons.js
try { (() => {
window.FSIcon = function FSIcon({
  name,
  size = 16,
  color = 'currentColor',
  style
}) {
  const url = 'https://unpkg.com/lucide-static@latest/icons/' + name + '.svg';
  return React.createElement('span', {
    style: {
      display: 'inline-block',
      width: size,
      height: size,
      backgroundColor: color,
      WebkitMaskImage: 'url(' + url + ')',
      maskImage: 'url(' + url + ')',
      WebkitMaskSize: 'contain',
      maskSize: 'contain',
      WebkitMaskRepeat: 'no-repeat',
      maskRepeat: 'no-repeat',
      flexShrink: 0,
      ...style
    }
  });
};
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/flowstock/icons.js", error: String((e && e.message) || e) }); }

// ui_kits/flowstock/screens/DashboardScreen.jsx
try { (() => {
function DashboardScreen({
  onNavigate
}) {
  const NS = window.FlowStockDesignSystem_93f696;
  const {
    Card,
    CardHeader,
    CardTitle,
    CardContent,
    Button,
    Input,
    Badge
  } = NS;
  const {
    MetricCard,
    StatusBadge
  } = NS;
  const Icon = window.FSIcon;
  const jobs = window.FS_DATA.jobs;
  const inventory = window.FS_DATA.inventory;
  const [quickInput, setQuickInput] = React.useState('');
  const [parsing, setParsing] = React.useState(false);
  const activeJobs = jobs.filter(j => !['collected', 'cancelled'].includes(j.status));
  const completed = jobs.filter(j => j.status === 'collected').length;
  const lowStock = inventory.filter(i => i.current_stock <= i.min_stock_level);
  const invValue = inventory.reduce((s, i) => s + i.current_stock * (i.sale_price || 0), 0);
  const completion = jobs.length ? (completed / jobs.length * 100).toFixed(1) : 0;
  const submitQuick = e => {
    e.preventDefault();
    if (!quickInput.trim()) return;
    setParsing(true);
    setTimeout(() => {
      setParsing(false);
      onNavigate('intake', {
        raw: quickInput
      });
    }, 900);
  };
  return /*#__PURE__*/React.createElement("div", {
    style: {
      padding: 24,
      background: 'var(--gradient-page)',
      minHeight: '100%',
      display: 'flex',
      flexDirection: 'column',
      gap: 24
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontSize: 24,
      fontWeight: 700,
      margin: 0,
      color: 'var(--foreground)'
    }
  }, "Dashboard"), /*#__PURE__*/React.createElement("p", {
    style: {
      color: 'var(--muted-foreground)',
      fontSize: 13,
      margin: '2px 0 0'
    }
  }, "Acme Repairs \xB7 Monday, Jul 13")), /*#__PURE__*/React.createElement("div", {
    style: {
      background: 'var(--gradient-brand)',
      borderRadius: 12,
      boxShadow: 'var(--shadow-md)',
      padding: 16
    }
  }, /*#__PURE__*/React.createElement("p", {
    style: {
      color: '#dbeafe',
      fontSize: 12,
      fontWeight: 600,
      display: 'flex',
      alignItems: 'center',
      gap: 6,
      margin: '0 0 8px'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "zap",
    size: 12,
    color: "#dbeafe"
  }), "Quick Intake \u2014 type the repair and hit Enter"), /*#__PURE__*/React.createElement("form", {
    onSubmit: submitQuick,
    style: {
      display: 'flex',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(Input, {
    value: quickInput,
    onChange: e => setQuickInput(e.target.value),
    placeholder: "e.g. John Smith \u2014 iPhone 15 Pro screen replacement",
    disabled: parsing,
    style: {
      flex: 1,
      height: 44,
      background: 'rgba(255,255,255,0.1)',
      border: '1px solid rgba(255,255,255,0.2)',
      color: '#fff'
    }
  }), /*#__PURE__*/React.createElement(Button, {
    type: "submit",
    disabled: parsing || !quickInput.trim(),
    style: {
      height: 44,
      background: '#fff',
      color: 'var(--blue-700)'
    }
  }, parsing ? '...' : /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Icon, {
    name: "zap",
    size: 14
  }), "Go")))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: 'repeat(4,1fr)',
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(MetricCard, {
    title: "Active Jobs",
    value: activeJobs.length,
    sub: completion + '% completion rate',
    color: "blue",
    iconGlyph: /*#__PURE__*/React.createElement(Icon, {
      name: "wrench",
      size: 18,
      color: "#fff"
    })
  }), /*#__PURE__*/React.createElement(MetricCard, {
    title: "Completed",
    value: completed,
    sub: "All time",
    color: "green",
    iconGlyph: /*#__PURE__*/React.createElement(Icon, {
      name: "circle-check",
      size: 18,
      color: "#fff"
    })
  }), /*#__PURE__*/React.createElement(MetricCard, {
    title: "Inventory Value",
    value: '$' + invValue.toLocaleString(),
    sub: inventory.length + ' items',
    color: "purple",
    iconGlyph: /*#__PURE__*/React.createElement(Icon, {
      name: "dollar-sign",
      size: 18,
      color: "#fff"
    })
  }), /*#__PURE__*/React.createElement(MetricCard, {
    title: "Low Stock",
    value: lowStock.length,
    sub: lowStock.length ? 'Needs attention' : 'All good',
    color: lowStock.length ? 'red' : 'blue',
    iconGlyph: /*#__PURE__*/React.createElement(Icon, {
      name: "triangle-alert",
      size: 18,
      color: "#fff"
    })
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '2fr 1fr',
      gap: 24
    }
  }, /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(CardHeader, {
    style: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(CardTitle, {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "clock",
    size: 16,
    color: "var(--blue-500)"
  }), "Recent Repairs"), /*#__PURE__*/React.createElement(Button, {
    variant: "ghost",
    size: "sm",
    onClick: () => onNavigate('kanban'),
    style: {
      color: 'var(--blue-600)'
    }
  }, "View all \u2192")), /*#__PURE__*/React.createElement(CardContent, {
    style: {
      padding: 0
    }
  }, jobs.slice(0, 6).map(job => /*#__PURE__*/React.createElement("div", {
    key: job.id,
    onClick: () => onNavigate('kanban'),
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      padding: '12px 20px',
      borderTop: '1px solid var(--border)',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("p", {
    style: {
      fontSize: 14,
      fontWeight: 600,
      margin: 0,
      color: 'var(--slate-800)'
    }
  }, job.title), /*#__PURE__*/React.createElement("p", {
    style: {
      fontSize: 12,
      color: 'var(--muted-foreground)',
      margin: '2px 0 0'
    }
  }, job.customer_name)), /*#__PURE__*/React.createElement(StatusBadge, {
    status: job.status
  }))))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(CardHeader, null, /*#__PURE__*/React.createElement(CardTitle, {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "trending-up",
    size: 16,
    color: "var(--purple-500)"
  }), "Job Pipeline")), /*#__PURE__*/React.createElement(CardContent, {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, ['intake', 'diagnosis', 'waiting_parts', 'in_repair', 'quality_check', 'ready'].map(s => {
    const count = jobs.filter(j => j.status === s).length;
    return /*#__PURE__*/React.createElement("div", {
      key: s,
      style: {
        display: 'flex',
        justifyContent: 'space-between'
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 13,
        color: 'var(--slate-600)',
        textTransform: 'capitalize'
      }
    }, s.replace('_', ' ')), /*#__PURE__*/React.createElement(StatusBadge, {
      status: s
    }));
  }))), lowStock.length > 0 && /*#__PURE__*/React.createElement(Card, {
    style: {
      background: 'var(--red-50)'
    }
  }, /*#__PURE__*/React.createElement(CardHeader, null, /*#__PURE__*/React.createElement(CardTitle, {
    style: {
      fontSize: 14,
      color: 'var(--red-700)',
      display: 'flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "triangle-alert",
    size: 14,
    color: "var(--red-700)"
  }), "Low Stock (", lowStock.length, ")")), /*#__PURE__*/React.createElement(CardContent, {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, lowStock.map(i => /*#__PURE__*/React.createElement("div", {
    key: i.id,
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      fontSize: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--slate-700)',
      fontWeight: 500
    }
  }, i.name), /*#__PURE__*/React.createElement(Badge, {
    variant: "destructive"
  }, i.current_stock))))))));
}
window.DashboardScreen = DashboardScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/flowstock/screens/DashboardScreen.jsx", error: String((e && e.message) || e) }); }

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Card = __ds_scope.Card;

__ds_ns.CardHeader = __ds_scope.CardHeader;

__ds_ns.CardTitle = __ds_scope.CardTitle;

__ds_ns.CardDescription = __ds_scope.CardDescription;

__ds_ns.CardContent = __ds_scope.CardContent;

__ds_ns.CardFooter = __ds_scope.CardFooter;

__ds_ns.Accordion = __ds_scope.Accordion;

__ds_ns.Avatar = __ds_scope.Avatar;

__ds_ns.Separator = __ds_scope.Separator;

__ds_ns.InventoryItemCard = __ds_scope.InventoryItemCard;

__ds_ns.KanbanCard = __ds_scope.KanbanCard;

__ds_ns.KanbanColumn = __ds_scope.KanbanColumn;

__ds_ns.MetricCard = __ds_scope.MetricCard;

__ds_ns.PriorityIcon = __ds_scope.PriorityIcon;

__ds_ns.StatusBadge = __ds_scope.StatusBadge;

__ds_ns.Alert = __ds_scope.Alert;

__ds_ns.Progress = __ds_scope.Progress;

__ds_ns.Skeleton = __ds_scope.Skeleton;

__ds_ns.Checkbox = __ds_scope.Checkbox;

__ds_ns.Input = __ds_scope.Input;

__ds_ns.Label = __ds_scope.Label;

__ds_ns.RadioGroup = __ds_scope.RadioGroup;

__ds_ns.Select = __ds_scope.Select;

__ds_ns.Textarea = __ds_scope.Textarea;

__ds_ns.Tabs = __ds_scope.Tabs;

__ds_ns.Dialog = __ds_scope.Dialog;

__ds_ns.DialogHeader = __ds_scope.DialogHeader;

__ds_ns.DialogTitle = __ds_scope.DialogTitle;

__ds_ns.DialogDescription = __ds_scope.DialogDescription;

__ds_ns.Popover = __ds_scope.Popover;

__ds_ns.Sheet = __ds_scope.Sheet;

__ds_ns.SheetHeader = __ds_scope.SheetHeader;

__ds_ns.SheetTitle = __ds_scope.SheetTitle;

__ds_ns.SheetDescription = __ds_scope.SheetDescription;

__ds_ns.Tooltip = __ds_scope.Tooltip;

})();
