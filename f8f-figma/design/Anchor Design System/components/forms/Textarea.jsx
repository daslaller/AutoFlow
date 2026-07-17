import React from 'react';
export function Textarea({style,rows=3,...props}){
  return React.createElement('textarea',{rows,style:{display:'flex',width:'100%',minHeight:'60px',borderRadius:'var(--radius-md)',border:'1px solid var(--input)',background:'transparent',padding:'8px 12px',fontSize:'14px',fontFamily:'var(--font-sans)',color:'var(--foreground)',boxShadow:'var(--shadow-sm)',outline:'none',resize:'vertical',...style},...props});
}
