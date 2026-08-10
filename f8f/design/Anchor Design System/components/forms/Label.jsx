import React from 'react';
export function Label({style,children,...props}){
  return React.createElement('label',{style:{fontSize:'14px',fontWeight:500,color:'var(--foreground)',display:'block',marginBottom:'6px',...style},...props},children);
}
