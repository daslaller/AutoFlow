import React from 'react';
export function RadioGroup({value,onValueChange,options=[],name='radio-group',style}){
  return React.createElement('div',{style:{display:'flex',flexDirection:'column',gap:8,...style}},
    options.map(o=>React.createElement('label',{key:o.value,style:{display:'flex',alignItems:'center',gap:8,fontSize:14,color:'var(--foreground)',cursor:'pointer'}},
      React.createElement('input',{type:'radio',name,checked:value===o.value,onChange:()=>onValueChange&&onValueChange(o.value),style:{accentColor:'var(--primary)',width:16,height:16}}),
      o.label)));
}
