package com.may.crm.workbench.service;

import com.may.crm.workbench.domain.ActivitiesRemark;

import java.util.List;

public interface ActivityRemarkService {

    List<ActivitiesRemark> queryActivityRemarkForDetailByActivityId(String activityId);
}
