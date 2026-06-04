// 10. 如果是這樣寫的話，有錯誤訊息，為什麼？
// btnGet.onclick = function () {
//     console.log("OK");
// }

// 11. 畫面準備好以後才開始執行
$(document).ready(function () {
  btnGet.onclick = function () {
    // 20. 取得 姓名欄位 (使用 JavaScript 的方式)
    // let a = document.getElementById("userName").value;
    // console.log(a);
    // 21. 取得 姓名欄位 (使用 jQuery 的方式)
    let a1 = $("#userName").val();
    console.log(a1);

    // 30. 取得 地址欄位 (使用 JavaScript 的方式)
    // let z = document.getElementById("address").value;
    // console.log(z);
    // 31. 取得 地址欄位 (使用 jQuery 的方式)
    let z1 = $("#address").val();
    console.log(z1);

    // 40. 取得 年紀欄位 (使用 JavaScript 的方式)
    // 1. 找到所有跟年紀有關的
    // 2.一個一個問有沒有被點選
    // 3.有點選才要抓出來在主控台
    let list = document.getElementsByName("age");
    for (let k = 0; k < list.length; k++) {
      let apple = list[k].checked;
    //   console.log(apple);
      if (apple == true) {
        console.log(list[k].value);
        
      }
    }

    // 41. 取得 年紀欄位 (使用 jQuery 的方式)
  };
});
