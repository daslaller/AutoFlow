import React from 'react';
export function Select({value,onValueChange,options=[],placeholder,style}){
  return React.createElement('select',{value:value||'',onChange:e=>onValueChange&&onValueChange(e.target.value),style:{display:'flex',height:'36px',width:'100%',borderRadius:'var(--radius-md)',border:'1px solid var(--input)',background:'transparent',padding:'0 10px',fontSize:'14px',fontFamily:'var(--font-sans)',color:'var(--foreground)',boxShadow:'var(--shadow-sm)',outline:'none',...style}},
    [placeholder&&React.createElement('option',{key:'_ph',value:'',disabled:true},placeholder), ...options.map(o=>React.createElement('option',{key:o.value,value:o.value},o.label))]);
}
