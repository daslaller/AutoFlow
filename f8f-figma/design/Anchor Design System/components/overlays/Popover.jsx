import React from 'react';
export function Popover({trigger,children}){
  const [open,setOpen]=React.useState(false);
  return React.createElement('div',{style:{position:'relative',display:'inline-block'}},
    React.createElement('div',{onClick:()=>setOpen(o=>!o)},trigger),
    open&&React.createElement('div',{style:{position:'absolute',top:'100%',left:0,marginTop:6,background:'var(--card)',border:'1px solid var(--border)',borderRadius:'var(--radius-lg)',boxShadow:'var(--shadow-lg)',padding:12,zIndex:30,minWidth:180}},children));
}
