import React from 'react';
const kinds={info:{bg:'var(--blue-50)',fg:'var(--blue-700)',border:'var(--blue-200)'},warning:{bg:'var(--yellow-50)',fg:'var(--yellow-700)',border:'var(--yellow-100)'},success:{bg:'var(--green-100)',fg:'var(--green-700)',border:'var(--green-100)'},destructive:{bg:'var(--red-50)',fg:'var(--red-700)',border:'var(--red-100)'}};
export function Alert({kind='info',title,children,style}){
  const k=kinds[kind]||kinds.info;
  return React.createElement('div',{style:{background:k.bg,color:k.fg,border:'1px solid '+k.border,borderRadius:'var(--radius-lg)',padding:'12px 14px',fontSize:13,...style}},
    title&&React.createElement('div',{style:{fontWeight:700,marginBottom:2}},title), children);
}
