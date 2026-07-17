import React from 'react';
const PRIORITY_BORDER={low:'var(--green-400)',medium:'#facc15',high:'var(--orange-500)',urgent:'var(--red-400)'};
const CATEGORY_COLOR={Bug:{bg:'var(--red-100)',fg:'var(--red-700)'},Feature:{bg:'var(--blue-100)',fg:'#1d4ed8'},Task:{bg:'var(--green-100)',fg:'var(--green-700)'},Project:{bg:'var(--purple-100)',fg:'var(--purple-700)'},Other:{bg:'var(--orange-100)',fg:'var(--orange-700)'}};
export function KanbanCard({title,detail,category='Other',tags=[],priority='medium',assigneeInitial,onClick}){
  const c=CATEGORY_COLOR[category]||CATEGORY_COLOR.Other;
  return React.createElement('div',{onClick,style:{background:'#fff',borderRadius:8,padding:16,marginBottom:12,boxShadow:'var(--shadow-md)',borderLeft:'4px solid '+PRIORITY_BORDER[priority],cursor:'pointer'}},
    React.createElement('div',{style:{fontWeight:600,color:'var(--slate-800)',marginBottom:6}},title),
    detail&&React.createElement('div',{style:{fontSize:13,color:'var(--muted-foreground)',marginBottom:8}},detail),
    React.createElement('div',{style:{display:'flex',flexWrap:'wrap',gap:6,marginBottom:12}},
      React.createElement('span',{style:{fontSize:11,fontWeight:600,padding:'2px 8px',borderRadius:6,background:c.bg,color:c.fg}},category),
      tags.map(t=>React.createElement('span',{key:t,style:{fontSize:11,padding:'2px 8px',borderRadius:6,background:'var(--muted)',color:'var(--muted-foreground)'}},t))),
    React.createElement('div',{style:{display:'flex',justifyContent:'flex-end',alignItems:'center'}},
      assigneeInitial&&React.createElement('div',{style:{width:24,height:24,borderRadius:'50%',background:'var(--gradient-brand-soft)',color:'#fff',fontSize:11,fontWeight:700,display:'flex',alignItems:'center',justifyContent:'center'}},assigneeInitial)));
}
