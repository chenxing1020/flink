/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.flink.runtime.dispatcher.runner;

import org.apache.flink.runtime.dispatcher.DispatcherId;
import org.apache.flink.runtime.highavailability.JobResultStore;
import org.apache.flink.runtime.jobgraph.JobGraph;
import org.apache.flink.runtime.jobmanager.ThrowingExecutionPlanWriter;
import org.apache.flink.runtime.jobmaster.JobResult;
import org.apache.flink.runtime.rpc.FatalErrorHandler;
import org.apache.flink.util.CollectionUtil;
import org.apache.flink.util.Preconditions;

import javax.annotation.Nullable;

import java.util.UUID;

/** {@link DispatcherLeaderProcess} implementation for the per-job mode. */
public class JobDispatcherLeaderProcess extends AbstractDispatcherLeaderProcess {

    private final DispatcherGatewayServiceFactory dispatcherGatewayServiceFactory;

    @Nullable private final JobGraph jobGraph;
    @Nullable private final JobResult recoveredDirtyJobResult;

    private final JobResultStore jobResultStore;

    JobDispatcherLeaderProcess(
            UUID leaderSessionId,
            DispatcherGatewayServiceFactory dispatcherGatewayServiceFactory,
            @Nullable JobGraph jobGraph,
            @Nullable JobResult recoveredDirtyJobResult,
            JobResultStore jobResultStore,
            FatalErrorHandler fatalErrorHandler) {
        super(leaderSessionId, fatalErrorHandler);
        this.dispatcherGatewayServiceFactory = dispatcherGatewayServiceFactory;
        this.jobGraph = jobGraph;
        this.recoveredDirtyJobResult = recoveredDirtyJobResult;
        this.jobResultStore = Preconditions.checkNotNull(jobResultStore);
    }

    @Override
    protected void onStart() {
        final DispatcherGatewayService dispatcherService =
                dispatcherGatewayServiceFactory.create(
                        DispatcherId.fromUuid(getLeaderSessionId()),
                        CollectionUtil.ofNullable(jobGraph),
                        CollectionUtil.ofNullable(recoveredDirtyJobResult),
                        ThrowingExecutionPlanWriter.INSTANCE,
                        jobResultStore);

        completeDispatcherSetup(dispatcherService);
    }
}
