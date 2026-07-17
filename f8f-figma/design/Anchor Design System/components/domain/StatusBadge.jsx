import React from 'react';
const STATUS={backlog:{bg:'--status-backlog-bg',fg:'--status-backlog-fg',label:'Backlog'},triage:{bg:'--status-triage-bg',fg:'--status-triage-fg',label:'Triage'},blocked:{bg:'--status-blocked-bg',fg:'--status-blocked-fg',label:'Blocked'},in_progress:{bg:'--status-inprogress-bg',fg:'--status-inprogress-fg',label:'In Progress'},review:{bg:'--status-review-bg',fg:'--status-review-fg',label:'Review'},ready:{bg:'--status-ready-bg',fg:'--status-ready-fg',label:'Ready'},done:{bg:'--status-done-bg',fg:'--status-done-fg',label:'Done'},cancelled:{bg:'--status-cancelled-bg',fg:'--status-cancelled-fg',label:'Cancelled'}};
export function StatusBadge({status='backlog',style}){
  const s=STATUS[status]||STATUS.backlog;
  return React.createElement('span',{style:{display:'inline-flex',alignItems:'center',padding:'3px 10px',borderRadius:'var(--radius-md)',fontSize:12,fontWeight:600,background:'var('+s.bg+')',color:'var('+s.fg+')',fontFamily:'var(--font-sans)',whiteSpace:'nowrap',...style}},s.label);
}
