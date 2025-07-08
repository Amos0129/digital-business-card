針對 request / response 的錯誤捕捉

`400 BadRequestException`  
此類型的錯誤僅將錯誤訊息留在後端, 呼叫端拿到代號

`403 ForbiddenException`  
此類型的錯誤僅將錯誤訊息留在後端, 呼叫端拿到"存取被拒"

`415 InvalidMediaTypeException`  
Request Header Type 錯誤才會回傳此錯誤, 基本上是為了弱掃而加上的

`417 ExpectationFailedException`  
此類型的錯誤僅將錯誤訊息留在後端, 呼叫端會拿到組裝好的錯誤訊息

`500 Exception`  
此類型的錯誤僅將錯誤訊息留在後端, 呼叫端拿到"未知錯誤"