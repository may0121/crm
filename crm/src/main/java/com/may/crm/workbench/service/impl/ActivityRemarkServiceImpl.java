package com.may.crm.workbench.service.impl;

import com.may.crm.workbench.domain.ActivitiesRemark;
import com.may.crm.workbench.mapper.ActivitiesRemarkMapper;
import com.may.crm.workbench.service.ActivityRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author may
 * @date 2022/5/5 16:56
 */
@Service
public class ActivityRemarkServiceImpl implements ActivityRemarkService {
 @Autowired
    ActivitiesRemarkMapper activitiesRemarkMapper;
    @Override
    public List<ActivitiesRemark> queryActivityRemarkForDetailByActivityId(String activityId) {
        return activitiesRemarkMapper.selectActivitiesRemarkForDetailByActivityId(activityId);
    }
}
