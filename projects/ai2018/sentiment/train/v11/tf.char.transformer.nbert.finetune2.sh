base=./mount

if [ $SRC ];
  then echo 'SRC:' $SRC 
else
  SRC='char.nbert'
  echo 'use default SRC char.nbert'
fi 
dir=$base/temp/ai2018/sentiment/tfrecords/$SRC

fold=0
if [ $# == 1 ];
  then fold=$1
fi 
if [ $FOLD ];
  then fold=$FOLD
fi 

model_dir=$base/temp/ai2018/sentiment/model/v11/$fold/$SRC/tf.char.transformer.nbert.finetune2/
num_epochs=30

mkdir -p $model_dir/epoch 
cp $dir/vocab* $model_dir
cp $dir/vocab* $model_dir/epoch

exe=./train.py 
if [ "$INFER" = "1"  ]; 
  then echo "INFER MODE" 
  exe=./$exe 
  model_dir=$1
  fold=0
fi

if [ "$INFER" = "2"  ]; 
  then echo "VALID MODE" 
  exe=./$exe 
  model_dir=$1
  fold=0
fi

# from 72k epoch 16.45 change min lr from 5e-7 1e-7
python $exe \
        --bert_dir=$base/data/my-embedding/bert-char/ckpt/500000 \
        --num_finetune_words=3000 \
        --num_finetune_chars=3000 \
        --model=Transformer \
        --fold=$fold \
        --vocab $dir/vocab.txt \
        --model_dir=$model_dir \
        --train_input=$dir/train/'*,' \
        --test_input=$dir/test/'*,' \
        --info_path=$dir/info.pkl \
        --emb_dim 300 \
        --finetune_word_embedding=1 \
        --batch_size 32 \
        --buckets=128,256,320,512 \
        --batch_sizes 32,16,12,6,2 \
        --length_key content \
        --encoder_output_method=last \
        --eval_interval_steps 1000 \
        --metric_eval_interval_steps 1000 \
        --save_interval_steps 1000 \
        --save_interval_epochs=1 \
        --valid_interval_epochs=1 \
        --inference_interval_epochs=1 \
        --freeze_graph=1 \
        --optimizer=bert \
        --learning_rate=4e-6 \
        --min_learning_rate=1e-7 \
        --num_decay_epochs=30 \
        --warmup_steps=4000 \
        --num_epochs=$num_epochs \

