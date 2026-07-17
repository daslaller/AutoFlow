import React from 'react';
export function KanbanColumn({title,count,headerColor='var(--slate-200)',children}){
  return React.createElement('div',{style:{display:'flex',flexDirection:'column',background:'rgba(241,245,249,0.7)',borderRadius:'var(--radius-lg)',minHeight:200}},
    React.createElement('div',{style:{padding:14,borderTopLeftRadius:'var(--radius-lg)',borderTopRightRadius:'var(--radius-lg)',background:headerColor,display:'flex',justifyContent:'space-between',alignItems:'center'}},
      React.createElement('span',{style:{fontWeight:700,color:'var(--slate-800)'}},title),
      React.createElement('span',{style:{fontSize:13,fontWeight:600,color:'var(--slate-600)',background:'rgba(255,255,255,0.5)',borderRadius:'var(--radius-full)',padding:'1px 8px'}},count)),
    React.createElement('div',{style:{flex:1,padding:12}},children));
}
