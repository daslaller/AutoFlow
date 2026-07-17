import React from 'react';
const variants={
default:'background:var(--primary);color:var(--primary-foreground);box-shadow:var(--shadow-sm);',
destructive:'background:var(--destructive);color:var(--destructive-foreground);box-shadow:var(--shadow-sm);',
outline:'background:transparent;color:var(--foreground);border:1px solid var(--input);box-shadow:var(--shadow-sm);',
secondary:'background:var(--secondary);color:var(--secondary-foreground);box-shadow:var(--shadow-sm);',
ghost:'background:transparent;color:var(--foreground);',
link:'background:transparent;color:var(--primary);text-decoration:underline;text-underline-offset:4px;',
gradient:'background:var(--gradient-brand-soft);color:#fff;box-shadow:var(--shadow-sm);',
};
const sizes={default:'height:36px;padding:0 16px;font-size:14px;',sm:'height:32px;padding:0 12px;font-size:12px;',lg:'height:40px;padding:0 32px;font-size:14px;',icon:'height:36px;width:36px;padding:0;'};
export function Button({variant='default',size='default',disabled,style,children,...props}){
  const [hover,setHover]=React.useState(false);
  const base='display:inline-flex;align-items:center;justify-content:center;gap:8px;white-space:nowrap;border-radius:var(--radius-md);font-weight:500;font-family:var(--font-sans);transition:filter var(--duration-fast) var(--ease-standard),opacity var(--duration-fast);cursor:pointer;border:none;';
  const opacity = disabled? 'opacity:0.5;pointer-events:none;':'';
  const hoverFilter = hover && !disabled ? 'filter:brightness(0.94);' : '';
  const cssText = base+variants[variant]+sizes[size]+opacity+hoverFilter;
  return React.createElement('button',{disabled,onMouseEnter:()=>setHover(true),onMouseLeave:()=>setHover(false),style:{...styleStringToObject(cssText),...style},...props},children);
}
function styleStringToObject(css){const obj={};css.split(';').forEach(rule=>{const idx=rule.indexOf(':');if(idx<0)return;const k=rule.slice(0,idx).trim();const v=rule.slice(idx+1).trim();if(!k)return;const camel=k.replace(/-([a-z])/g,(_,c)=>c.toUpperCase());obj[camel]=v;});return obj;}
