import React from 'react';
export function Progress({value=0,style}){
  return React.createElement('div',{style:{width:'100%',height:8,borderRadius:'var(--radius-full)',background:'var(--muted)',overflow:'hidden',...style}},
    React.createElement('div',{style:{width:Math.min(100,Math.max(0,value))+'%',height:'100%',background:'var(--gradient-brand-soft)',borderRadius:'var(--radius-full)',transition:'width var(--duration-normal) var(--ease-standard)'}}));
}
