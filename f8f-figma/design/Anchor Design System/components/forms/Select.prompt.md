Select — dropdown for enum fields (status, priority, category).
```jsx
<Select value={status} onValueChange={setStatus} options={[{value:'intake',label:'Intake'},{value:'ready',label:'Ready'}]}/>
```