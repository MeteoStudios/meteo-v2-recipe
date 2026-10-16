return {
    ['cleankit'] = {
        name = "cleaning_vehicle",
        label = locale('progress.cleankit'),
        duration = 15000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
    },
    ['tirerepairkit'] = {
        name = "fixing_tire",
        label = locale('progress.tirerepairkit'),
        duration = 15000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            clip = "machinic_loop_mechandplayer",
            flag = 10
        },
    },
    ['smallkit'] = {
        name = "repairing_vehicle",
        label = locale('progress.smallkit'),
        duration = 20000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = "mini@repair",
            clip = "fixing_a_player"
        },
    },
    ['bigkit'] = {
        name = "advanced_repairing",
        label = locale('progress.bigkit'),
        duration = 30000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = "mini@repair",
            clip = "fixing_a_player"
        },
    }
}