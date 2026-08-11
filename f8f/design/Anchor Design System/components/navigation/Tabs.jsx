import React from 'react';
export function Tabs({value,onValueChange,tabs=[],children}){
  return React.createElement('div',null,
    React.createElement('div',{style:{display:'flex',gap:4,background:'var(--muted)',padding:4,borderRadius:'var(--radius-lg)'}},
      tabs.map(t=>React.createElement('button',{key:t.value,onClick:()=>onValueChange&&onValueChange(t.value),style:{flex:1,padding:'8px 12px',borderRadius:'var(--radius-md)',border:'none',fontSize:13,fontWeight:600,cursor:'pointer',fontFamily:'var(--font-sans)',background:value===t.value?'var(--card)':'transparent',color:value===t.value?'var(--foreground)':'var(--muted-foreground)',boxShadow:value===t.value?'var(--shadow-sm)':'none'}},t.label))),
    React.createElement('div',{style:{marginTop:16}},children));
}
