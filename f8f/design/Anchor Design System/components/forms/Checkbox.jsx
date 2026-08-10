import React from 'react';
export function Checkbox({checked,onCheckedChange,style,...props}){
  return React.createElement('input',{type:'checkbox',checked:!!checked,onChange:e=>onCheckedChange&&onCheckedChange(e.target.checked),style:{width:16,height:16,borderRadius:'4px',accentColor:'var(--primary)',...style},...props});
}
