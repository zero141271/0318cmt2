
## 日志打点指标说明

**时间相关指标说明**

| 指标                                 | 说明                                                  |
| ------------------------------------ | ----------------------------------------------------- |
| `timing/all`                         | 一次迭代总时间                                        |
| `timing/update`                      | 一次迭代中actor model进行update耗时                   |
| `timing/rollout`                     | 一次迭代中actor model进行rollout耗时                  |
| `timing/old_log_p`                   | 一次迭代中actor model计算logp耗时                     |
| `timing/reference_model`             | 一次迭代中reference model计算logp耗时                 |
| `timing/resharding_to_train`         | 权重转到训练mode耗时                                  |
| `timing/resharding_to_infer`         | 权重转到推理mode耗时                                  |
| `timing/adv`                         | 计算advantages耗时                                    |
| `timing/non_overlap_reference_model` | reference model计算logp耗时的未被掩盖时间               |
| `timing/non_overlap_rule_reward`     | rule_reward耗时的未被掩盖时间                         |
| `timing/non_overlap_reward_model`    | reward_model耗时的未被掩盖时间                        |
| `timing/non_overlap_adv`             | advantages计算耗时的未被掩盖时间                        |
| `timing/rule_reward`                 | rule reward打分耗时                                   |
| `timing/reward_model`                | reward model打分耗时                                  |
| `timing/ref_onload`                  | reference model计算logp过程中，onload耗时             |
| `timing/ref_offload`                 | reference model计算logp过程中，offload耗时            |

* 全共卡方案下总时间分布

`timing/all` >= `timing/rollout` +`timing/old_log_p` + `timing/update`  +  `timing/reference` + `timing/reshard_to_train` + `timing/reshard_to_infer`  + `max(timing/non_overlap_rule_reward, timing/non_overlap_reference_model)`


**其他指标**

| 指标                                 | 说明                                                         |
|------------------------------------| ------------------------------------------------------------ |
| `actor/entropy`                    | 策略熵，表示策略的随机性或探索能力                           |
| `actor/kl_loss`                    | kl散度，衡量当前策略与参考策略（如旧策略或参考模型）之间的偏离程度 |
| `actor/pg_loss`                    | pg_loss，基于优势函数的策略梯度目标函数值，表示当前策略对提升奖励的学习能力。 |
| `actor/pg_clipfrac`                | GRPO中裁剪机制生效的比例，反映了策略更新幅度的稳定性         |
| `actor/ppo_kl`                     | PPO算法的实际 KL 散度                                        |
| `grad_norm`                        | 梯度范数，表示当前反向传播中参数梯度的整体幅度               |
| `{verifier_function}_rewards/mean` | 规则奖励打分的平均总奖励值                                   |
| `actor/lr`                         | 学习率，优化器当前使用的学习率                               |
| `grpo/score/mean`                  | 开启奖励模型时的reward均值                                   |
| `grpo/score/max`                   | 奖励模型及规则奖励对同一个样本的reward最大值                 |
| `grpo/score/min `                  | 奖励模型及规则奖励对同一个样本的reward最小值                 |
| `grpo/rewards/mean`                | 规则奖励的reward均值；奖励模型对样本的reward经过归一化后的均值 |
| `grpo/rewards/max`                 | 规则奖励的reward最大值；奖励模型对样本的reward经过归一化后的最大值 |
| `grpo/rewards/min`                 | 规则奖励的reward最小值；奖励模型对样本的reward经过归一化后的最小值 |
| `response_length/mean`             | 平均生成长度，模型生成回复（response）的平均 token 数        |
| `response_length/min`              | 最短生成长度，当前 batch 中生成最短的 response 长度          |
| `response_length/max`              | 最长生成长度，当前 batch 中生成最长的 response 长度          |
| `prompt_length/mean`               | 平均输入长度，输入 prompt 的平均长度                         |
| `prompt_length/max`                | 最长输入长度，当前 batch 中最长的 prompt长度                 |
| `prompt_length/min`                | 最短输入长度，当前 batch 中最长的 prompt长度                 |
| `e2e_tps`                          | 端到端的tokens/p/s指标                                       |
| `update_tps`                       | 训练的tokens/p/s指标                                         |
| `vllm_tps`                         | 推理的tokens/p/s指标                                         |

* e2e_tps计算方式

$$
(\text{response\_length\_mean} + \text{prompt\_length\_mean}) \times \text{global\_batch\_size} \times \text{n\_samples\_per\_prompt} / \text{world\_size} \ / \text{time\_all}
$$

* update_tps计算方式

$$
(\text{response\_length\_mean} + \text{prompt\_length\_mean}) \times \text{global\_batch\_size} \times \text{n\_samples\_per\_prompt} / \text{world\_size} \ / \text{time\_update}
$$

* vllm_tps计算方式

$$
(\text{response\_length\_mean} + \text{prompt\_length\_mean}) \times \text{global\_batch\_size} \times \text{n\_samples\_per\_prompt} / \text{world\_size} \ / \text{time\_rollout}
$$
## 性能数据

| 模型                  | 机器型号     | GBS | n_samples | max_prompt_length | max_tokens | 端到端 tps | 
|---------------------|----------|-----|-----------|-------------------|------------|---------| 
| Qwen25-7B           | Atlas 900 A3 SuperPoD | 32  | 8         | 2048              | 2048       | 220     | 
| Qwen25-32B          | Atlas 900 A3 SuperPoD | 64  | 16        | 1024              | 2048       | 220     | 
| Qwen25-32B          | Atlas 900 A2 PODc | 64  | 16        | 1024              | 1024       | 100     |
| Qwen3-8B            | Atlas 900 A3 SuperPoD | 32  | 8         | 2048              | 8192       | 252     |
| DeepSeek-R1-671B    | Atlas 900 A3 SuperPoD | 384 | 32        | 1024              | 2048       | 210     |


注：模型 token/p/s 性能数据会打印在日志中, 当前计算公式下，A3单卡性能需要将日志打印的token/p/s性能指数*2。