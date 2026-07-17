import React from 'react';
export function Skeleton({style}){
  return React.createElement('div',{style:{background:'var(--slate-200)',borderRadius:'var(--radius-lg)',animation:'ds-pulse 1.5s ease-in-out infinite',...style}});
}
