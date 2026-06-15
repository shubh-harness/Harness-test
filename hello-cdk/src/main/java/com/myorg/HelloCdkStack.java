package com.myorg;

import software.constructs.Construct;
import software.amazon.awscdk.Stack;
import software.amazon.awscdk.StackProps;
import software.amazon.awscdk.CfnParameter;
import software.amazon.awscdk.CfnOutput;
import software.amazon.awscdk.services.ssm.StringParameter;

public class HelloCdkStack extends Stack {

    public HelloCdkStack(final Construct scope, final String id, final StackProps props,
                         final String defaultSecretName) {
        super(scope, id, props);

        CfnParameter sname = CfnParameter.Builder.create(this, "sname")
                .type("String")
                .defaultValue(defaultSecretName)
                .description("Secret name parameter for this stack")
                .build();

        StringParameter param = StringParameter.Builder.create(this, "TestParam")
                .parameterName("/" + id + "/secretName")
                .stringValue(sname.getValueAsString())
                .description("Test SSM parameter created by CDK for " + id)
                .build();

        CfnOutput.Builder.create(this, "outputId")
                .value(sname.getValueAsString())
                .description("The secret name output for this stack")
                .build();
    }
}
