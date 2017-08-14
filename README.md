**「适合 ansible 中级用户阅读」**

![ansible](https://mmbiz.qpic.cn/mmbiz_png/s0ClhYiavKgPerEBchLj4w0Zj5puRGEB3iaxhtd0V35KpoXQMrDRlAHpicibApicJGsR8VvSPb1nnia8OxPw4HcGE3EA/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

作为自动化执行、配置管理工具，Ansible 常被拿来和 puppet 比较。Ansible 具备简单，免 agent 的优点，是实现“基础设施即代码”的理想选择。通过使用 CMDB 生成 Host Inventory, 加上一个 Role 生成器自动生成 Playbook。可以进化到类似 Ansible Tower 的自动化平台。

## 1
* * *
## 最佳实践

swain-ansible 项目 (项目地址：[https://github.com/hg2c/swain-ansible](https://github.com/hg2c/swain-ansible)) 试图做到的是：

>- ansible script 工程模板/目录结构最佳实践；
>- 多环境支持最佳实践；
>- fact 管理最佳实践；
>- debug (vagrant, docker) 最佳实践；
>- 日常维护最佳实践；
>- 环境初始化最佳实践；
>- 快捷命令。


### 1.1
* * *
### 工程模板/目录结构

- roles: 放置标准的 [playbook role](http://docs.ansible.com/ansible/latest/playbooks_reuse_roles.html)。
- environments: 每个子目录是一套环境 ($ENV) 的配置。包含 hosts, group_vars 等。
- run: 运行时产生的临时文件。
- provider: 放置标准的 [playbooks](http://docs.ansible.com/ansible/latest/playbooks.html), 用于实现某一种初始化方案，比如关闭 selinux 并改变 dns 等。
- facts: 放置标准的 playbooks, 用于管理 fact。含检查 fact 是否被定义，设置 fact 的默认值，以及计算 fact。
- books: 放置标准的 playbooks, 用于实现某个小目标，比如安装 docker。
- plays: 放置标准的 playbooks, 用于实现某个大目标，比如安装 kubernetes。
- scripts: 放置标准的 playbooks, 用于实现日常维护功能，比如查看 consul 状态。
- .ansible: 快捷命令，比如 .ansible/script 等同于执行 ansible-playbook -i environments/$ENV/hosts scripts/consul.status.yml

### 1.2
* * *
### 多环境支持

**目标**

>- 同一套代码，只需指定环境名，就可以生成 dev, pref, prod 等基础环境：
>- 方便维护，易于添加，修改，删除环境。

**实现**

如果我们需要支持 dev, pref, prod 三套环境，则在 environments 目录下建立三个同名子目录：dev. pref, prod。每个子目录均为一套环境 ($ENV) 的配置。包含：

- hosts: 环境专属的 host inventory；
- ssh_config: inventory 用到的主机配置。不推荐放置在 $HOME/.ssh/config ，因为团队协作中，每个人的 .ssh/config 文件很可能不一致。
- group_vars: 放置环境专属的变量。

### 1.3
* * *
### FACT 管理

提高 ansible role 复用率。没有好的 fact 管理，不知道小伙伴用了那些 fact，不敢复用

### 1.4
* * *
### 快捷命令

- 提供快捷命令，比如 .ansible/script 等同于执行 ansible-playbook -i environments/$ENV/hosts scripts/consul.status.yml
- 都可以带参数 -x host1,host2，即限定这次 ansible-playbook 执行的主机范围。例如 .ansible/script debug -x a.dev.cn,b.dev.cn


## 2
* * *
## 使用实例

### 2.1
* * *
###  验证基本配置正常

1. ansible-playbook -i environments/dev/hosts books/_debug.yml

### 2.2
* * *
### （集群扩容）在 dev 环境新增 2 个 k8s-node: 1.1.1.2，1.1.1.3，需对这两台主机设置 docker.thinpool：

1. 在 ./environments/dev/ssh_config 里配置新节点的名字，比如 f.dev.cn 和 g.dev.cn ；
2. 在 ./environments/dev/hosts 里配置新节点所属组：kubernetes-minion ；
3. 执行 .ansible/script dev docker.thinpool -X f.dev.cn,g.dev.cn （用 -X 参数限定脚本只跑在这两台主机上）。

## 3
* * *
## 项目地址
> swain-ansible ：[https://github.com/hg2c/swain-ansible](https://github.com/hg2c/swain-ansible)
