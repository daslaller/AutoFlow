import React from 'react';
export function Separator({style}){
  return React.createElement('div',{style:{height:1,width:'100%',background:'var(--border)',...style}});
}
