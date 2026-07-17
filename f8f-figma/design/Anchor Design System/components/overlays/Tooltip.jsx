import React from 'react';
export function Tooltip({label,children}){
  const [show,setShow]=React.useState(false);
  return React.createElement('span',{style:{position:'relative',display:'inline-block'},onMouseEnter:()=>setShow(true),onMouseLeave:()=>setShow(false)},
    children,
    show&&React.createElement('span',{style:{position:'absolute',bottom:'100%',left:'50%',transform:'translateX(-50%)',marginBottom:6,background:'var(--slate-900)',color:'#fff',fontSize:11,padding:'4px 8px',borderRadius:6,whiteSpace:'nowrap',zIndex:50}},label));
}
