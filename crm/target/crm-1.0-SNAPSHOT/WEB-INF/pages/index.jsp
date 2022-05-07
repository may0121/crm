<%--html文件重命名为jsp,要设置编码格式如下，再重命名--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
	<meta charset="UTF-8">
</head>
<body>
<script type="text/javascript">
<%--	index.jsp不用"/",因为就在当前的pages目录下面
		加/就表明从根目录开始
		--%>
	window.location.href = "settings/qx/user/toLogin.do";
</script>
</body>
</html>