import React from 'react';
const PRI={low:{color:'var(--priority-low)',glyph:'↓'},medium:{color:'var(--priority-medium)',glyph:'↑'},high:{color:'var(--priority-high)',glyph:'⇈'},urgent:{color:'var(--priority-urgent)',glyph:'⇊'}};
export function PriorityIcon({priority='medium',style}){
  const p=PRI[priority]||PRI.medium;
  return React.createElement('span',{title:priority,style:{color:p.color,fontWeight:700,fontSize:14,...style}},p.glyph);
}
