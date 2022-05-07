package com.may.crm.workbench.web.controller;

import com.may.crm.commons.constant.Constant;
import com.may.crm.commons.domain.ReturnObject;
import com.may.crm.commons.utils.DateUtils;
import com.may.crm.commons.utils.HSSFUtils;
import com.may.crm.commons.utils.UUIDUtils;
import com.may.crm.settings.domain.User;
import com.may.crm.settings.service.UserService;
import com.may.crm.workbench.domain.ActivitiesRemark;
import com.may.crm.workbench.domain.Activity;
import com.may.crm.workbench.service.ActivityRemarkService;
import com.may.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.InputStream;
import java.util.*;

/**
 * @author may
 * @date 2022/4/28 13:59
 */
//跳转到市场活动主页面
    @Controller
    public class ActivityController {

    @Autowired
    private ActivityService activityService;
    @Autowired
    private UserService userService;
    @Autowired
    private ActivityRemarkService activityRemarkService;

    @RequestMapping("/workbench/activity/index.do")
    public String index(HttpServletRequest request) {
        //       调用service层 查询 用户信息
        List<User> userList = userService.selectAllUsers();
        //        将用户数据存入request作用域中
        request.setAttribute("userList", userList);
        //      跳转到活动首页
        return "workbench/activity/index";
    }

    /**
     * 1.这是一个异步请求，因为创建活动旨在活动那一块变化，上面的信息没有变化
     * 2.创建活动之后，仍然返回到activity主页面
     * 3.数据类型为object ，因为ajax发送的请求，后面响应传来的信息也有ajax接收
     * ajax只能解析json对象，object可以返回任何对象类型
     * 4.responsebody，ajax的标识
     */

    @RequestMapping("/workbench/activity/saveCreateActivity.do")
    @ResponseBody
    public Object saveCreateActivity(HttpSession session, Activity activity) {
//   数据库中有9个数据，但是前面用户只输入了6个数据，剩下的三个数据需要手动存进去

//       存数据首先要得到用户，之前通过session存过登录用户的信息
        User user = (User) session.getAttribute(Constant.SESSION_USER);
//        封装用户信息
//        确定id的唯一性，UUID
        activity.setId(UUIDUtils.getUUID());
//        活动创建的时间，使用之前的工具类
        activity.setCreateTime(DateUtils.formateDateTime(new Date()));
//        创建活动的人，是谁登录的就是谁创建的活动，这里要使用用户的信息，传用户的id，以为id不会重复，姓名会重复
        activity.setCreateBy(user.getId());
//       处理业务信息，使用之前的returnobject工具
        ReturnObject returnObject = new ReturnObject();
        try {
//        调用Activityservice层，保存创建的活动信息 ret表示影响的行数
            int ret = activityService.saveCreatActivity(activity);
            if (ret > 0) {//如果ret大于0的话，说明执行成功
//             设置returnObject 的状态，让前端判断是否保存成功
                returnObject.setCode(Constant.RETURN_OBJECT_CODE_SUCCESS);
            } else {//保存失败。设置状态
                returnObject.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
//                提示信息
                returnObject.setMessage("系统忙，请稍后再试..");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
//            如果产生异常，同样提示信息
            returnObject.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后再试..");
        }
        return returnObject;
    }

    /**
     * 市场活动分页查询功能 返回Json字符串
     *
     * @param
     * @return
     */
    @RequestMapping("/workbench/activity/queryActivityByConditionForPage.do")
    @ResponseBody
    public Object queryActivityByConditionForPage(String name, String owner, String startDate, String endDate,
                                                  Integer pageNo, Integer pageSize) {
//      用map  封装前端的数据
        Map<String, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("startDate", startDate);
        map.put("endDate", endDate);
        map.put("beginNo", (pageNo - 1) * pageSize); //起始条数 （当前页码-1）*每页显示条数
        map.put("pageSize", pageSize);
//       调用service层查询数据
//        根据封装的条件分页查询数据
        List<Activity> activityList = activityService.queryActivityByConditionForPage(map);
//        查询所有记录条数
        int totalRows = activityService.queryCountOfActivityByCondition(map);
//        System.out.println("tatalRows"+tat0lRows);
//        用map对象（或者实体类对象）来封装这两个数据
        Map<String, Object> resMap = new HashMap<>();
        resMap.put("activityList", activityList);
        resMap.put("totalRows", totalRows);
//        返回转为json对象
        return resMap;
    }

    //    按id删除市场信息
    @RequestMapping("/workbench/activity/deleteActivityByIds.do")
    @ResponseBody
    public Object deleteActivityByIds(String[] id) {//参数名和前端穿入的信息保持一致
//        用工具类设置判断信息,用json响应信息
        ReturnObject returnObject = new ReturnObject();
//        try catch可以打印提示错误信息
        try {
//        调用service层处理业务逻辑
            int res = activityService.deleteActivityByIds(id);
            if (res > 0) {
                returnObject.setCode(Constant.RETURN_OBJECT_CODE_SUCCESS);
            } else {
                returnObject.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统忙，请稍后再试...");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
            returnObject.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后再试...");
        }
        return returnObject;
    }

    /**
     * 根据id查询市场活动，然后通过json字符串讲市场活动信息
     * 显示到市场活动模态窗（ajax异步请求）
     *
     * @param
     * @return
     */

    @RequestMapping("/workbench/activity/queryActivityById.do")
    @ResponseBody
    public Object queryActivityById(String id) {
//        通过service层查询信息，json显示信息
        Activity activity = activityService.queryActivityById(id);
        return activity;
    }

    /**
     * 修改市场活动信息，依旧是局部刷新，异步请求
     *
     * @param activity 封装修改的信息
     * @return object 返回json字符串
     */
    @RequestMapping("/workbench/activity/updateActivity.do")
    @ResponseBody
    public Object updateActivity(Activity activity, HttpSession session) {
        //       存数据首先要得到用户，之前通过session存过登录用户的信息
        User user = (User) session.getAttribute(Constant.SESSION_USER);
        activity.setEditBy(user.getId());
        activity.setEditTime(DateUtils.formateDateTime(new Date()));
//        使用工具类来设置判断信息
        ReturnObject returnObject = new ReturnObject();
        try {
//        调用业务层处理业务
            int res = activityService.updateActivityById(activity);
            if (res > 0) {
                returnObject.setCode(Constant.RETURN_OBJECT_CODE_SUCCESS);
            } else {
                returnObject.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统忙，请稍后再试...");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
            returnObject.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后再试...");
        }
        return returnObject;
    }

    /**
     * 批量导出市场活动到excel表格
     * 该方法是跳转浏览器下载页面，所以不需要给前端返回信息
     *
     * @param response 响应
     * @throws Exception 输出流异常
     */
    @RequestMapping("/workbench/activity/exportAllActivity.do")
    public void exportAllActivity(HttpServletResponse response) throws Exception {
        //调用service层方法，查询所有的市场活动
        List<Activity> activityList = activityService.queryAllActivities();
        //创建exel文件，并且把activityList写入到excel文件中
        HSSFUtils.createExcelByActivityList(activityList, Constant.FILE_NAME_ACTIVITY, response);
    }

    /**
     * 根据选择的id 部分导出市场活动
     *
     * @param id 选择的市场活动
     * @return
     */
    @RequestMapping("/workbench/activity/exportCheckedActivity.do")
    public void exportCheckedActivity(String[] id, HttpServletResponse response) throws Exception {
        // 调用service层方法，查询所有的市场活动
        List<Activity> activityList = activityService.queryCheckedActivity(id);
        // 创建excel文件，并且把activityList写入到excel文件中
        HSSFUtils.createExcelByActivityList(activityList, Constant.FILE_NAME_ACTIVITY, response);
    }

    /**
     * 批量导入市场活动
     *
     * @param
     * @return
     */
    @RequestMapping("/workbench/activity/importActivity.do")
    @ResponseBody
    public Object importActivity(MultipartFile activityFile, HttpSession session) {
        User user = (User) session.getAttribute(Constant.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();
        try {
            InputStream is = activityFile.getInputStream();
            HSSFWorkbook wb = new HSSFWorkbook(is);
            // 根据wb获取HSSFSheet对象，封装了一页的所有信息
            HSSFSheet sheet = wb.getSheetAt(0); // 页的下标，下标从0开始，依次增加
            // 根据sheet获取HSSFRow对象，封装了一行的所有信息
            HSSFRow row = null;
            HSSFCell cell = null;
            Activity activity = null;
            List<Activity> activityList = new ArrayList<>();
            for (int i = 1; i <= sheet.getLastRowNum(); i++) { // sheet.getLastRowNum()：最后一行的下标
                row = sheet.getRow(i); // 行的下标，下标从0开始，依次增加
                System.out.println("row得值："+row);
                activity = new Activity();
                // 补充部分参数
                activity.setId(UUIDUtils.getUUID());
                activity.setOwner(user.getId());
                activity.setCreateTime(DateUtils.formateDateTime(new Date()));
                activity.setCreateBy(user.getId());
                for (int j = 0; j < row.getLastCellNum(); j++) { // row.getLastCellNum():最后一列的下标+1
                    // 根据row获取HSSFCell对象，封装了一列的所有信息
                    cell = row.getCell(j); // 列的下标，下标从0开始，依次增加
                    System.out.println("cell得值："+cell);
                    // 获取列中的数据
                    String cellValue = HSSFUtils.getCellValueForStr(cell);
                    if (j == 0) {
                        activity.setName(cellValue);
                    } else if (j == 1) {
                        activity.setStartDate(cellValue);
                    } else if (j == 2) {
                        activity.setEndDate(cellValue);
                    } else if (j == 3) {
                        activity.setCost(cellValue);
                    } else if (j == 4) {
                        activity.setDescription(cellValue);
                    }
                }
                //每一行中所有列都封装完成之后，把activity保存到list中
                activityList.add(activity);
            }
            // 调用service层方法，保存市场活动
            int res = activityService.saveActivitiesByList(activityList);
            returnObject.setCode(Constant.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setOther(res);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 点开市场活动跳转到明细页面
     * @param
     * @return
     */
    @RequestMapping("/workbench/activity/activityDetail.do")
    public String activityDetail(String id,HttpServletRequest request){
//        调用service层显示市场活动详情和评论信息
       Activity activity =  activityService.queryActivityForDetailById(id);
        List<ActivitiesRemark> remarkList = activityRemarkService.queryActivityRemarkForDetailByActivityId(id);
//        把数据存到作用域中
        request.setAttribute("activity",activity);
        request.setAttribute("remarkList",remarkList);
//        请求转发
        return "workbench/activity/detail";

    }
}
