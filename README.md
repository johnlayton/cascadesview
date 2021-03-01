## bitbucket

### Setup oh-my-zsh

#### Install buildkite plugin
```zsh
pushd $ZSH/custom/plugins && \
  git clone git@github.com:johnlayton/cascadesview.git bitbucket && \
  popd || echo "I'm broken"
```
```zsh
plugins=(... buildkite)
```

### Setup other

```zsh
pushd $HOME && \
  git clone git@github.com:johnlayton/cascadesview.git .bitbucket && \
  popd || echo "I'm broken"
```

```zsh
source ~/.bitbucket/bitbucket.plugin.zsh
```


### Usage

#### 
```zsh
```

#### 
```zsh
```

#### 
```zsh
```
