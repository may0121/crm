<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
	// 设置动态初始访问路径（这里本地是http://127.0.0.1:8080/crm/）
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>

<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="
jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="
jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript">

	$(function (){
		/*
		给整个浏览器窗口天剑键盘按下事件
		1.window代表整个窗口，DOM事件  用ajax取$(window)
		2.keydown,代表键盘按下键触发事件，每一个键都有值
		3.event 代表事件，e是缩写，把整个keydown事件作为函数的参数
		 */
		$(window).keydown(function (e){
		//	如果按下的事回车键，则提交登录请求
			if (e.keyCode==13){
		//  如果条件成立，模拟发生单击事件（按钮已经绑定了函数，这里不需要绑定函数）
				$("#loginBtn").click();
			}
		});

		// 给登录按钮添加单机事件
		$("#loginBtn").click(function () {
			// 收集表单参数
			var loginAct = $.trim($("#loginAct").val());
			var loginPwd = $.trim($("#loginPwd").val());
			var isRemPwd = $("#isRemPwd").prop("checked");
			// 表单验证
			if (loginAct == "") {
				alert("用户名不能为空");
				return;
			}
			if (loginPwd == "") {
				alert("密码不能为空");
				return;
			}
			//显示正在验证
			// $("#msg").text("正在验证...");

			// 发送请求
			$.ajax({
				url:"settings/qx/user/login.do",
				data:{
					loginAct:loginAct,
					loginPwd:loginPwd,
					isRemPwd:isRemPwd
				},
				type:"post", // 使用get和post都可以，但是get会有缓存，修改前端界面候需要清除缓存，不方便
				dataType:"json",
				success:function (data) { // 发送请求成功后接收到的后台响应
					if (data.code == "1") { // 登录成功，跳转至业务主页面
						window.location.href = "workbench/index.do";
					} else { // 登录失败，输出响应信息
						$("#msg").text(data.message);
					}
				},

					/*
					1.当ajax向后台发送请求之前，会自动执行本函数
					2.该函数的返回值能够决定ajax是否真正向后台发送请求
					3.如果该函数返回true值，ajax发送请求，返回false则不发送求情

					 */
				beforeSend:function (){
					$("#msg").text("正在验证...");
					return true;
				}

			});

		});
	});
</script>
</head>
<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2022&nbsp;may</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.html" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" id="loginAct" type="text" value="${cookie.loginAct.value}" placeholder="用户名">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" id="loginPwd" type="password"  value="${cookie.loginPwd.value}" placeholder="密码">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">
						<label>
							<c:if test="${not empty cookie.loginAct and not empty cookie.loginPwd}">
								<input type="checkbox" id="isRemPwd" checked>
							</c:if>
							<c:if test="${empty cookie.loginAct or empty cookie.loginPwd}">
								<input type="checkbox" id="isRemPwd">
							</c:if>
							 十天内免登录
						</label>
						&nbsp;&nbsp;
						<span id="msg"></span>
					</div>
					<button type="button"  id="loginBtn" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>