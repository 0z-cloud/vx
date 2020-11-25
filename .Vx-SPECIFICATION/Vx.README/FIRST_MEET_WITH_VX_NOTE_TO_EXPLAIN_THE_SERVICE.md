# It's again micro helper for fast educate repository quanta-sync-ci-flows.

    * `Completed Flow` - it's a Scope of Pipelines which must to be applyed and deployed for some scope of primary root Production Inventory -

    I.      INFRA UP! - 

                ```
                As results, will be a '0z-cloud Inventory', which
                must to contain the 'Result Map of Servers Group',
                on your local physic or virtual network 'zone',
                with correct entities and instances variables data.

                CALLED: 'Stand Deploy/Bootstrap/Extend and Validate'
                PLACED: 'Before!' in chain, where executes 'cloud_regen.sh'
                ```

    II.     LAYOUT GO! - 

                ```
                Internal services section, you select your backend services, such as databases, 
                queue, storage, messaging or calculation and other particular services and applications, which your application uses for store, transfer, change and view some data in your application developed and relesed features needs, as in a simple words - 'Service Layer'.

                CALLED: 'Service Layer and Internal Services Warmup and Check'
                PLACED: 'After!' 'cloud_regen.sh' exec in chain, 'Before' deploy set.
                ```

    III.    RUN RE/BUILD & RE/DEPLOY! - 

                ```
                Two phases section, first 'BuildAndPush' - build all your docker images and push them to private docker registry, second, - 'Generates Configuration Map', for selected from presets, or writed on examples by you itself infrastructure layout and size, and then apply them on your cluster or any want configuration map to deploy.

                CALLED: 'Build, Push, Deploy, Zen'
                PLACED: 'In CI/CD chain, after Service Layer Success check return'
                ```

    IV.     BACKEND UPDATE & DISCOVERY SERVICES - 

                ```
                In different installations in that step first tasks it's in overall company sets is a databases migrations or some schema updates. After 'critical' checks defaults next step go runned and will apply new services publish configuration options and send to wants destinations hosts groups needed for him special configuration checks, which helps node to join and interact to infrastructure layout fastest way.

                CALLED: 'DNS Backend with Nginx Frontend and co.'
                PLACED: 'After deploy set, CI/CD step four'
                ```

    V.      FULL COVERAGE QUALITY ASSURANCE :) - 

                ```
                Stay that for QA team...to explain...may be no need?
                QA? What you say?

                Really magic step, which control your GitFlow Work proccesses and not can do be able to pass any bad builded source to your live systems.

                CALLED: 'QA! QA! QA!'
                PLACED: 'Step five, but you can do your arrange'
                ```


# Little note

    (*)     PRODUCT AS ENVIRONMENT EXTEND - 

                ```
                A little good tick it is use a ANSIBLE_PRODUCT as FAKE environment root.
                ```