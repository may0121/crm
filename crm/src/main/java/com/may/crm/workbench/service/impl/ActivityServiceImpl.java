package com.may.crm.workbench.service.impl;

import com.may.crm.workbench.domain.Activity;
import com.may.crm.workbench.mapper.ActivityMapper;
import com.may.crm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * @author may
 * @date 2022/4/28 15:14
 */
//市场活动的service
@Service("activityServiceImpl")
public class ActivityServiceImpl implements ActivityService {
//    调用mapper层
    @Autowired
    private    ActivityMapper activityMapper;

    @Override
    public int saveCreatActivity(Activity activity) {
        return activityMapper.insertActivity(activity);
    }

    @Override
    public List<Activity> queryActivityByConditionForPage(Map<String, Object> map) {
        return activityMapper.selectActivityByConditionForPage(map);
    }

    @Override
    public int queryCountOfActivityByCondition(Map<String, Object> map) {
        return activityMapper.selectCountOfActivityByCondition(map);
    }

    @Override
    public int deleteActivityByIds(String[] ids) {
        return activityMapper.deleteActivityByIds(ids);
    }

    @Override
    public Activity queryActivityById(String id) {
        return activityMapper.queryActivityById(id);
    }

    @Override
    public int updateActivityById(Activity activity) {
        return activityMapper.updateActivityById(activity);
    }

    @Override
    public List<Activity> queryAllActivities() {
        return activityMapper.queryAllActivities();
    }

    @Override
    public List<Activity> queryCheckedActivity(String[] id) {
        return activityMapper.queryCheckedActivity(id);
    }

    @Override
    public int saveActivitiesByList(List<Activity> activityList) {
        return activityMapper.insertActivitiesByList(activityList);
    }

    @Override
    public Activity queryActivityForDetailById(String id) {
        return activityMapper.selectActivityForDetailById(id);
    }


}
