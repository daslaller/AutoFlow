import React from 'react';
export function Avatar({initial,size=32,style}){
  return React.createElement('div',{style:{width:size,height:size,borderRadius:'50%',background:'var(--gradient-brand-soft)',display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontWeight:700,fontSize:size*0.4,boxShadow:'0 0 0 2px #fff',...style}},(initial||'?').slice(0,1).toUpperCase());
}
