import React from 'react';
const variants={
default:{background:'var(--primary)',color:'var(--primary-foreground)'},
secondary:{background:'var(--secondary)',color:'var(--secondary-foreground)'},
destructive:{background:'var(--destructive)',color:'var(--destructive-foreground)'},
outline:{background:'transparent',color:'var(--foreground)',border:'1px solid var(--border)'},
};
export function Badge({variant='default',style,children,...props}){
  const v=variants[variant]||variants.default;
  return React.createElement('span',{style:{display:'inline-flex',alignItems:'center',borderRadius:'var(--radius-md)',padding:'2px 10px',fontSize:'12px',fontWeight:600,fontFamily:'var(--font-sans)',whiteSpace:'nowrap',...v,...style},...props},children);
}
