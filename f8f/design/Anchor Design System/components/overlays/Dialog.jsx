import React from 'react';
export function Dialog({open,onOpenChange,children}){
  if(!open) return null;
  return React.createElement('div',{style:{position:'fixed',inset:0,zIndex:50,display:'flex',alignItems:'center',justifyContent:'center'}},
    React.createElement('div',{onClick:()=>onOpenChange&&onOpenChange(false),style:{position:'absolute',inset:0,background:'rgba(0,0,0,0.4)'}}),
    React.createElement('div',{style:{position:'relative',background:'var(--card)',borderRadius:'var(--radius-xl)',boxShadow:'var(--shadow-xl)',padding:24,maxWidth:480,width:'90%',maxHeight:'85vh',overflowY:'auto'}},children));
}
export function DialogHeader({children,style}){return React.createElement('div',{style:{marginBottom:16,...style}},children);}
export function DialogTitle({children,style}){return React.createElement('div',{style:{fontSize:18,fontWeight:700,color:'var(--foreground)',...style}},children);}
export function DialogDescription({children,style}){return React.createElement('div',{style:{fontSize:13,color:'var(--muted-foreground)',marginTop:4,...style}},children);}
