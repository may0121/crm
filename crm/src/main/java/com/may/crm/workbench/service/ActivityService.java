package com.may.crm.workbench.service;

import com.may.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;


public interface ActivityService {
//    保存创建活动
    int saveCreatActivity(Activity activity);
//    按条件分页查询数据
    List<Activity> queryActivityByConditionForPage(Map<String,Object> map);
//    查询活动总条数
    int queryCountOfActivityByCondition(Map<String,Object> map);
//    按id删除市场活动
    int deleteActivityByIds(String  [] ids);
//   按id查询信息
    Activity queryActivityById(String id);
//    修改选中的市场活动信息
    int updateActivityById(Activity activity);
//    查询所有市场活动信息
    List<Activity> queryAllActivities();
//   查询选中的市场活动
    List<Activity> queryCheckedActivity(String[] id);
//  批量导入文件
    int saveActivitiesByList(List<Activity> activityList);
//    查询市场活动明细
    Activity queryActivityForDetailById(String id);
}
