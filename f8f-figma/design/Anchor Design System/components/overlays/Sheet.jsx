import React from 'react';
export function Sheet({open,onOpenChange,children}){
  return React.createElement(React.Fragment,null,
    open&&React.createElement('div',{onClick:()=>onOpenChange&&onOpenChange(false),style:{position:'fixed',inset:0,background:'rgba(0,0,0,0.4)',zIndex:40}}),
    React.createElement('div',{style:{position:'fixed',top:0,right:0,bottom:0,width:'min(480px,92vw)',background:'var(--card)',boxShadow:'var(--shadow-xl)',zIndex:41,padding:24,overflowY:'auto',transform:open?'translateX(0)':'translateX(100%)',transition:'transform var(--duration-normal) var(--ease-standard)'}},children));
}
export function SheetHeader({children}){return React.createElement('div',{style:{marginBottom:20}},children);}
export function SheetTitle({children}){return React.createElement('div',{style:{fontSize:22,fontWeight:700,color:'var(--foreground)'}},children);}
export function SheetDescription({children}){return React.createElement('div',{style:{fontSize:13,color:'var(--muted-foreground)',marginTop:4}},children);}
