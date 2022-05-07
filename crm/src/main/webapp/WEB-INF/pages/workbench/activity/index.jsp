<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--导入jstl标签库做遍历处理--%>
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
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css" type="text/css" rel="stylesheet">


<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
<script type="text/javascript">

	$(function() {
		//	给创建按钮添加单击事件
		$("#createActivityBtn").click(function () {

			//	重置创建表单的信息，每次点开就是新的没有数据的表单
			//	$("#createActivityForm").get(0)  jquery获取dom对象，reset重置
			$("#createActivityForm").get(0).reset();
			//	弹出创建市场活动的模拟窗口
			$("#createActivityModal").modal("show");

		});

		//给保存按钮添加单击事件
		/**
		 *	给保存按钮添加单击 s事件
		 */
		$("#saveCreateActivityBtn").click(function () {
			//	收集创建市场活动的数据  对于用户手动输入的数据要手动去空格
			var owner = $("#create-marketActivityOwner").val();
			var name = $.trim($("#create-marketActivityName").val());
			var startDate = $("#create-startDate").val();
			var endDate = $("#create-endDate").val();
			var cost = $.trim($("#create-cost").val());
			var description = $("#create-description").val();

			//表单验证
			//	创建者和活动吗不能为空
			if (owner == "") {
				alert("创建者不能为空")
				return;
			}
			if (name == "") {
				alert("活动名不能为空")
				return;
			}
			//结束时间不能比开始时间早
			if (endDate !== "" && startDate !== "") {
				//用字符串代替日期比较大小
				if (endDate < startDate) {
					alert("结束日期不能早于开始日期")
					return;
				}
			}
			//正则表达式判断成本只能为非负整数
			var regExp = /^(([1-9]\d*)|0)$/;
			if (!regExp.test(cost)) {
				alert("成本只能为非负整数");
				return;
			}

			//	条件成立发送请求
			$.ajax({
				//要跳转的页面
				url: "workbench/activity/saveCreateActivity.do",
				//参数名要和controller中接收参数的实体类的属性名一致
				data: {
					owner: owner,
					name: name,
					startDate: startDate,
					endDate: endDate,
					cost: cost,
					description: description
				},
				type: "post",
				dataType: "json",
				//处理响应接收信息
				success: function (data) {
					//	解析json 渲染页面，判断是否成功
					if (data.code == 1) {
						//	保存成功关闭模拟窗口
						$("#createActivityModal").modal("hide");
						// 刷新市场活动列，显示第一页数据
						queryActivityByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));

					} else {
						//	创建活动失败，提示信息，窗口不关闭
						alert(data.message);
						$("#createActivityModal").modal("show");
					}

				}

			});

		});

		//	 开始结束日期日历实现：bootstrap的datetimepicker插件（为了方便统一格式）
		//	   分别加上日历比较繁琐，在开始日期和结束日期后面加上class
		$(".mydate").datetimepicker({
			language: "zh-CN",//语言
			format: "yyyy-mm-dd",//格式
			minView: "month",//可以选择的最小视图
			initialDate: new Date(),//初始化显示的日期
			autoclose: true,//设置选择玩日期或事件后，日期是否自动关闭
			todayBtn: true,//是否显示今天按钮，默认false
			clearBtn: true,//是否 显示清空按钮，默认false
		});


		//当市场活动主页面加载完成，查询所有数据的第一页以及所有数据的总条数,默认每页显示10条
		queryActivityByConditionForPage(1, 10);

		//给"查询"按钮添加单击事件
		$("#queryActivityBtn").click(function () {
			//查询所有符合条件数据的第一页以及所有符合条件数据的总条数;（使用插件的函数）
			//第一页不变，根据之前用户选择的每页显示条数，显示查询页面的条数
			queryActivityByConditionForPage(1, $("#demo_page1").bs_pagination("getOption", "rowsPerPage"));
		});

		// 给全选按钮添加事件实现全选（全选按钮在市场数据被查出来之前已经生成了，所以直接给固有元素全选按钮添加事件即可）
		$("#checkAll").click(function () {
			// 如果全选按钮选中，则列表中所有按钮都选中（操作tbody下面的所有子标签input，设置为当前（this）全选按钮的状态）
			$("#tBody input[type='checkbox']").prop("checked", this.checked);
		});
		// 当市场活动标签不是全选时取消全选按钮
		// 此时的市场数据未被查询出来，即input中的内容不存在
		// （因为异步请求向后端查询数据的过程相对于前端代码加载比较漫长，所以肯定前端代码执行完毕后动态数据才能加载出来）
		// 所以只能通过这种方式给动态元素添加事件
		$("tBody").on("click", "input[type='checkbox']", function () {
			// 设置全选标签状态，如果当前所有标签数和选中标签数相等，则全选，否则不全选
			$("#checkAll").prop("checked",
					$("#tBody input[type='checkbox']").size() == $("#tBody input[type='checkbox']:checked").size());
		});

		//给删除按钮添加事件
		/**
		 *	给删除按钮添加单击 s事件
		 */
		$("#deleteActivityBtn").click(function () {
			//	收集参数，获取列表中被选中的checkbox
			//	tbody  下input标签所有被选中的checkbox类型 是一个数组
			var checkedids = $("tBody input[type='checkbox']:checked")
			if (checkedids.size() == 0) {
				//	如果没有被选中，就不能删除，结束方法
				alert("请选择要删除的市场活动")
				return;
			}
			//	是否确定删除，是一个阻塞窗口，不点击就一直在，如果确定就传值true，然后继续执行代码
			if (window.confirm("确定要删除吗？")) {
				//用一个大字符串接收  变量名与后台参数保持一致
				var id = "";
				//	遍历数组 得到id的值
				$.each(checkedids, function () {
					id = "id=" + this.value + "&"//id=xxx&.....id=xxxx&
				});
				// 截取字符串，id=xxx...&id=xxx
				id = id.substr(0, id.length - 1);
				//	发送请求
				$.ajax({
					url: 'workbench/activity/deleteActivityByIds.do',
					data: id,//是一个字符串
					type: 'post',
					dataType: 'json',
					success: function (data) {
						if (data.code == "1") {
							//	刷新市场活动，显示第一页数据，保持每页显示条数不变
							queryActivityByConditionForPage(1, $("#demo_page1").bs_pagination("getOption", "rowsPerPage"));
						} else {
							// 失败 就打印提示信息
							alert(data.message);
						}
					}
				});
			}
		});

		//  给修改按钮添加单击事件
		/**
		 *	给修改按钮添加单击 s事件
		 */
		$("#editActivityBtn").click(function () {
			//获取选中的市场活动checkbox
			var checkedid = $("#tBody input[type=checkbox]:checked");
			//	判断选中的值既不能为0也不能大于1
			if (checkedid == 0) {
				alert("请选择你要删除的数据")
				return;
			}
			if (checkedid > 1) {
				alert("每次只能修改一个数据")
				return;
			}
			//	获取选中的id值
			var id = checkedid[0].value;
			//  验证通过发送请求
			$.ajax({
				url: 'workbench/activity/queryActivityById.do',
				data: {
					id: id//一个属性值
				},
				type: 'post',
				dataType: 'json',
				success: function (data) {
					//	收集市场活动的信息，显示到模态窗口
					$("#edit-id").val(data.id);
					$("#edit-marketActivityOwner").val(data.owner);
					$("#edit-marketActivityName").val(data.name);
					$("#edit-startTime").val(data.startDate);
					$("#edit-endTime").val(data.endDate);
					$("#edit-cost").val(data.cost);
					$("#edit-describe").val(data.description);
					//	显示模态窗口
					$("#editActivityModal").modal("show");
				}
			})
		});

		/**
		 *	给更新按钮添加单击 s事件
		 */
		$("#updateActivityBtn").click(function () {
			//	收集创建市场活动的数据  对于用户手动输入的数据要手动去空格
			var id = $("#edit-id").val(); // 隐藏input标签value值
			var owner = $("#edit-marketActivityOwner").val();
			var name = $.trim($("#edit-marketActivityName").val());
			var startDate = $("#edit-startTime").val();
			var endDate = $("#edit-endTime").val();
			var cost = $.trim($("#edit-cost").val());
			var description = $("#edit-describe").val();

			//表单验证
			//	创建者和活动吗不能为空
			if (owner == "") {
				alert("创建者不能为空")
				return;
			}
			if (name == "") {
				alert("活动名不能为空")
				return;
			}
			//结束时间不能比开始时间早
			if (endDate !== "" && startDate !== "") {
				//用字符串代替日期比较大小
				if (endDate < startDate) {
					alert("结束日期不能早于开始日期")
					return;
				}
			}
			//正则表达式判断成本只能为非负整数
			var regExp = /^(([1-9]\d*)|0)$/;
			if (!regExp.test(cost)) {
				alert("成本只能为非负整数");
				return;
			}
			//	条件成立发送请求
			$.ajax({
				//要跳转的页面
				url: "workbench/activity/updateActivity.do",
				//参数名要和controller中接收参数的实体类的属性名一致
				data: {
					id:id,
					owner: owner,
					name: name,
					startDate: startDate,
					endDate: endDate,
					cost: cost,
					description: description
				},
				type: "post",
				dataType: "json",
				//处理响应接收信息
				success: function (data) {
					//	解析json 渲染页面，判断是否成功
					if (data.code == 1) {
						//	保存成功关闭模拟窗口
						$("#editActivityModal").modal("hide");
						// 刷新市场活动列，显示更新候的数据所在页面 修改的时候显示第几页 修改后还是显示第几页
						queryActivityByConditionForPage($("#page-master").bs_pagination('getOption', 'currentPage'),
								                        $("#page-master").bs_pagination('getOption', 'rowsPerPage'));

					} else {
						//	创建活动失败，提示信息，窗口不关闭
						alert(data.message);
						$("#editActivityModal").modal("show");
					}

				}
			});
		//	给取消的按钮添加单击事件
			$("#closeupdateActivityBtn").click(function (){
				$("#editActivityModal").modal("hide");
			});

		});
		  /**
		  *	 给批量下载添加单击按钮
		  */
		$("#exportActivityAllBtn").click(function (){
			window.location.href="workbench/activity/exportAllActivity.do";
		});

		/**
		*	 给部分下载添加单击按钮
		*/
		$("#exportActivityXzBtn").click(function () {
			// 收集参数（获取所有checkbox）
			var activityIds = $("#tBody input[type='checkbox']:checked");
			if (activityIds.size() == 0) { // 如果未选中市场活动
				alert("请选择要导出的市场活动");
				return;
			}
			//用一个大字符串接收  变量名与后台参数保持一致
			var id = "";
			//	遍历数组 得到id的值
			$.each(activityIds, function () {
				id = "id=" + this.value + "&"//id=xxx&.....id=xxxx&
			});
			// 截取字符串，id=xxx...&id=xxx
			id = id.substr(0, id.length - 1);
				//发送同步请求
				window.location.href = "workbench/activity/exportCheckedActivity.do?id="+id;
		});

		/**
		 *	 给导入按钮添加单击按钮
		 */
		$("#importActivityBtn").click(function (){
			//收集参数
			var activityFileName =  $("#activityFile").val();
		//	截取文件后缀，指定文件上传的类型
			var suffix = activityFileName.substr(activityFileName.lastIndexOf(".")+1).toLowerCase();//转换成小写
		//	对文件类型进行判断
			if (suffix!=="xls"){
				alert("只支持xls文件");
				return ;
			}
		//	获取文件（dom对象），file属性是一个数组，但是目前浏览器只支持一种文件类型所以
		//	所以获取files【0】
			var activityFile = $("#activityFile").get(0).files[0];
		//	对文件大小进行判断，文件不能超过5MB
			if (activityFile.size>5*1024*1024){
				alert("文件不能超过5MB");
				return ;
			}
			// FormData是ajax提供的接口,可以模拟键值对向后台提交参数;
			// FormData最大的优势是不但能提交文本数据，还能提交二进制数据
			var formData = new FormData();
			//name:  value:
			formData.append("activityFile",activityFile);
		//	发送请求
			$.ajax({
				url:'workbench/activity/importActivity.do',
				data:formData,
				processData:false,// 设置ajax向后台提交参数之前，是否把参数统一转换成字符串：true--是,false--不是,默认是true
				contentType:false,// 设置ajax向后台提交参数之前，是否把所有的参数统一按urlencoded编码：true--是,false--不是，默认是true
				type:'post',
				dataType:'json',
				success:function (data){
					if (data.code=="1"){
					//	导入成功提示成功导入的条数
						alert("成功导入"+data.other+"条");
					//	关闭模态窗口
						$("#importActivityModal").modal("hide");
					// 刷新市场活动列表,显示第一页数据,保持每页显示条数不变
						queryActivityByConditionForPage(1, $("#page-master").bs_pagination('getOption', 'rowsPerPage'));
					}else {
					//	提示失败信息
						alert(data.message);
					//	窗口不关闭
						$("#importActivityModal").modal("show");
					}
				}

			});
		//	给取消按钮加单击事件
			$("#importdown").click(function (){
				$("#importActivityModal").modal("hide");
			});
		});

	});

	//封装函数要在入口函数外封装
	/**
	 * 分页查询函数功能：封装参数并发送请求
	 * @param pageNo 起始页码
	 * @param pageSize 单页显示数据条数
	 */
	function queryActivityByConditionForPage(pageNo, pageSize) {
		//收集参数
		var name = $("#query-name").val();
		var owner = $("#query-owner").val();
		var startDate = $("#query-startDate").val();
		var endDate = $("#query-endDate").val();
		//这里不要钻牛角尖，就是显示第一页十条，与后面的公式无关
		// var pageNo=1;
		// var pageSize=10;
		//发送请求
		$.ajax({
			url: 'workbench/activity/queryActivityByConditionForPage.do',
			data: {
				name: name,
				owner: owner,
				startDate: startDate,
				endDate: endDate,
				pageNo: pageNo,
				pageSize: pageSize
			},
			type: 'post',
			dataType: 'json',
			success: function (data) {
				//显示总条数(单词一定不要写错！！)
				// $("#totalRowsB").text(data.totalRows)
				//显示市场活动的列表
				//遍历activityList，拼接所有行数据
				var htmlStr = "";
				$.each(data.activityList, function (index, obj) {
					htmlStr += "<tr class=\"active\">";
					htmlStr += "<td><input type=\"checkbox\" value=\"" + obj.id + "\"/></td>";
					htmlStr += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='detail.jsp';\">" + obj.name + "</a></td>";
					htmlStr += "<td>" + obj.owner + "</td>";
					htmlStr += "<td>" + obj.startDate + "</td>";
					htmlStr += "<td>" + obj.endDate + "</td>";
					htmlStr += "</tr>";
				});
				//将数据写入页面
				$("#tBody").html(htmlStr);
				// 换页时将全选按钮取消选中
				$("#checkAll").prop("checked", false);
				//计算总共多少页
				var totalPages = 1;
				if (data.totalRows % pageSize == 0) {
					//	可以整除
					totalPages = data.totalRows / pageSize;
				} else {
					//不能整除,页面不能是小数，所以转为整数
					totalPages = parseInt(data.totalRows / pageSize) + 1;
				}

				//对容器调用bs_pagination工具函数，显示翻页信息
				$("#demo_page1").bs_pagination({
					currentPage: pageNo, // 当前页号,相当于pageNo
					rowsPerPage: pageSize, // 每页显示条数,相当于pageSize
					totalRows: data.totalRows, // 总条数
					totalPages: totalPages,  // 总页数,必填参数.
					visiblePageLinks: 5, // 最多可以显示的卡片数
					showGoToPage: true, // 是否显示"跳转到"部分，默认true显示
					showRowsPerPage: true, // 是否显示"每页显示条数"部分，默认true显示
					showRowsInfo: true, // 是否显示记录的信息，默认true显示
					// 用户每次切换页号，都自动触发本函数;
					// 每次返回切换页号之后的pageNo和pageSize
					// onChangePage: function (event, pageObj) { // returns page_num and rows_per_page after a link has clicked
					// 	// 重写发送当前页数和每页显示的条数（这也就意味着每次换页都将向后端 发送请求 查询当页数据）
					// 	queryActivityByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
					onChangePage: function (event, pageObj) { // returns page_num and rows_per_page after a link has clicked
						// 重写发送当前页数和每页显示的条数（这也就意味着每次换页都将向后端 发送请求 查询当页数据）
						queryActivityByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
					}
				});
			}
		});
	}
	
</script>
</head>
<body>

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form" id="createActivityForm">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: #ff0000;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
								  <c:forEach items="${userList}" var="u">
<%--									  后台是取到的id值  显示用户的姓名--%>
									  <option value="${u.id} ">${u.name}</option>
								  </c:forEach>
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-startDate">
							</div>
							<label for="create-startDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-endDate">
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" id="closeCreateActivityBtn" >关闭</button>
					<button type="button" class="btn btn-primary" id="saveCreateActivityBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
<%--					加一个隐藏域，保存id 的值--%>
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
									<c:forEach items="${userList}" var="u">
										<%--									  后台是取到的id值  显示用户的姓名--%>
										<option value="${u.id} ">${u.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-startTime" value="2020-10-10">
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-endTime" value="2020-10-20">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" value="5,000">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" id="closeupdateActivityBtn">关闭</button>
					<button type="button" class="btn btn-primary"id="updateActivityBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 导入市场活动的模态窗口 -->
    <div class="modal fade" id="importActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
                </div>
                <div class="modal-body" style="height: 350px;">
                    <div style="position: relative;top: 20px; left: 50px;">
                        请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                    </div>
                    <div style="position: relative;top: 40px; left: 50px;">
                        <input type="file" id="activityFile">
                    </div>
                    <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;" >
                        <h3>重要提示</h3>
                        <ul>
                            <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                            <li>给定文件的第一行将视为字段名。</li>
                            <li>请确认您的文件大小不超过5MB。</li>
                            <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                            <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                            <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                            <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal" id="importdown">关闭</button>
                    <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
                </div>
            </div>
        </div>
    </div>
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="query-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="query-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="query-startDate" readonly/>
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="query-endDate" readonly>
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="queryActivityBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createActivityBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editActivityBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				<div class="btn-group" style="position: relative; top: 18%;">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal" ><span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）</button>
                    <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）</button>
                    <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）</button>
                </div>
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll" /></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="tBody">
<%--						<tr class="active">--%>
<%--							<td><input type="checkbox" /></td>--%>
<%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>--%>
<%--                            <td>zhangsan</td>--%>
<%--							<td>2020-10-10</td>--%>
<%--							<td>2020-10-20</td>--%>
<%--						</tr>--%>
<%--                        <tr class="active">--%>
<%--                            <td><input type="checkbox" /></td>--%>
<%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>--%>
<%--                            <td>zhangsan</td>--%>
<%--                            <td>2020-10-10</td>--%>
<%--                            <td>2020-10-20</td>--%>
<%--                        </tr>--%>
					</tbody>
				</table>
				<div id="demo_page1"></div>
			</div>
<%--			--%>
<%--			<div style="height: 50px; position: relative;top: 30px;">--%>
<%--				<div>--%>
<%--					<button type="button" class="btn btn-default" style="cursor: default;">共<b id="totalRowsB">50</b>条记录</button>--%>
<%--				</div>--%>
<%--				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">--%>
<%--					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>--%>
<%--					<div class="btn-group">--%>
<%--						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">--%>
<%--							10--%>
<%--							<span class="caret"></span>--%>
<%--						</button>--%>
<%--						<ul class="dropdown-menu" role="menu">--%>
<%--							<li><a href="#">20</a></li>--%>
<%--							<li><a href="#">30</a></li>--%>
<%--						</ul>--%>
<%--					</div>--%>
<%--					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>--%>
<%--				</div>--%>
<%--				<div style="position: relative;top: -88px; left: 285px;">--%>
<%--					<nav>--%>
<%--						<ul class="pagination">--%>
<%--							<li class="disabled"><a href="#">首页</a></li>--%>
<%--							<li class="disabled"><a href="#">上一页</a></li>--%>
<%--							<li class="active"><a href="#">1</a></li>--%>
<%--							<li><a href="#">2</a></li>--%>
<%--							<li><a href="#">3</a></li>--%>
<%--							<li><a href="#">4</a></li>--%>
<%--							<li><a href="#">5</a></li>--%>
<%--							<li><a href="#">下一页</a></li>--%>
<%--							<li class="disabled"><a href="#">末页</a></li>--%>
<%--						</ul>--%>
<%--					</nav>--%>
<%--				</div>--%>
<%--			</div>--%>
			
		</div>
		
	</div>
</body>
</html>