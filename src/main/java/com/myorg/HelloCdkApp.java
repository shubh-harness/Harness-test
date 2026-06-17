package com.myorg;

import software.amazon.awscdk.App;
import software.amazon.awscdk.Environment;
import software.amazon.awscdk.StackProps;

public class HelloCdkApp {
    public static void main(final String[] args) {
        App app = new App();

        String stack1Name = (String) app.getNode().tryGetContext("stack1_name");
        String stack2Name = (String) app.getNode().tryGetContext("stack2_name");

        if (stack1Name == null) {
            stack1Name = "HelloCdkStack1";
        }
        if (stack2Name == null) {
            stack2Name = "HelloCdkStack2";
        }

        Environment env = Environment.builder()
                .account(System.getenv("CDK_DEFAULT_ACCOUNT"))
                .region(System.getenv("CDK_DEFAULT_REGION"))
                .build();

        StackProps stackProps = StackProps.builder().env(env).build();

        new HelloCdkStack(app, stack1Name, stackProps,
                "defaultSecretNameStack1");

        new HelloCdkStack(app, stack2Name, stackProps,
                "defaultSecretNameStack2");

        app.synth();
    }
}
