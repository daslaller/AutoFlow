import React from 'react';
export function Input({style,...props}){
  return React.createElement('input',{style:{display:'flex',height:'36px',width:'100%',borderRadius:'var(--radius-md)',border:'1px solid var(--input)',background:'transparent',padding:'0 12px',fontSize:'14px',fontFamily:'var(--font-sans)',color:'var(--foreground)',boxShadow:'var(--shadow-sm)',outline:'none',...style},...props});
}
