import { useMemberInfo } from 'reducer/member-info'

export default () => {
  const memberInfo = useMemberInfo()[0]

  return (
    <div className='p-3 border border-secondary rounded'>
      <h1>Home Page</h1>
      hi, {memberInfo.name}
    </div>
  )
}
