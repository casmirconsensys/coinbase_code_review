  //Link, Media file, Category, Token Reward, Progress, Field, Bounty_ChainID, Bounty_ID, Bounty_Name, Bounty_Link, Bounty_Media, Bounty_Capital, Bounty_Currency, Bounty_Emoji, Bounty_EmojiU
query ($id: ID!) {
    chain_ID(ID: $id) {
      chain_id
      rpc
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
    }
  }
