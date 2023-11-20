const { TokenERC20History } = require("@thirdweb-dev/sdk")
const bounties = require("../../../vbn-vfluence-main/controllers/bounties")

{
    ChainId(code: "EVM") {
        name
        bounties {          
            bounty_id
            name
            link
            media
            category
            token_reward
            field
            progress
        }
        TokenERC20History{}
    }
    }