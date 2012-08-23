#ifndef __QUEUE_H__
#define __QUEUE_H__

//
// inline functions
//

static inline uint8_t *Q_NEXT(uint8_t * const qp, uint8_t * const start, uint8_t * const end) 
{
	uint8_t *qo = qp;
	if(qo == end || (qo+1) == end)
		return start;
	else
	  return qo+1;
}

static inline int Q_EMPTY(uint8_t * const head, uint8_t * const tail) 
{
	return(head == tail);
}

// Push data to tail of queue
static inline void Q_PUSH(uint8_t v, uint8_t * volatile *head, uint8_t * volatile *tail, uint8_t * const start, uint8_t * const end) 
{
	uint8_t *next = *tail;
	next = Q_NEXT(next, start, end);
	// If the queue is full, dump the oldest data
	if(next == *head)
		*head = Q_NEXT(*head, start, end);

	**tail = v;
	*tail = next;
}

// Pop from head of queue, does not check if queue is non-empty first!
static inline uint8_t Q_POP_UNSAFE(uint8_t * volatile *head, uint8_t * const start, uint8_t * const end) 
{
	uint8_t r = **head;
	*head = Q_NEXT(*head, start, end);
	return r;
}

static inline int Q_POP(uint8_t *r, uint8_t * volatile *head, uint8_t * const tail, uint8_t * const start, uint8_t * const end) 
{
	if(!Q_EMPTY(*head, tail)) {
		*r = Q_POP_UNSAFE(head, start, end);
		return 1;
	} else
		return 0;
}

// Peek head of queue, does not check if queue is non-empty first!
static inline uint8_t Q_PEEK_UNSAFE(uint8_t * volatile *head)
{
	uint8_t r = **head;
	return r;
}

static inline int Q_PEEK(uint8_t *r, uint8_t * volatile *head, uint8_t * const tail)
{
	if(!Q_EMPTY(*head, tail)) {
		*r = Q_PEEK_UNSAFE(head);
		return 1;
	} else
		return 0;
}

static inline unsigned  int Q_LENGTH(uint8_t * volatile *head, uint8_t * const tail, uint8_t * const start, uint8_t * const end) {
	int n = tail - *head;
	if(n < 0)
		n += (end - start);
	return n;
}

// Look for a particular value on the queue, return the distance from the head, -1 if value is not present
static inline unsigned int Q_FIND(uint8_t f, uint8_t * const head, uint8_t * const tail, uint8_t * const start, uint8_t * const end) {
	uint8_t *next = head;
	int i = 0;
	for(i=0; next != tail; ++i) {
		if(*next == f)
			return i;
		next = Q_NEXT(next, start, end);
	}
	return -1;
}


//
//  generic routines
//

#define Q_LOG_2_SIZE      10
// derived - do not edit
#define Q_SIZE            (1<<(Q_LOG_2_SIZE))

#define QUEUE_DECLARE(q)                              \
  uint8_t q##_buf[Q_SIZE];                            \
  uint8_t * const q##_end = &q##_buf[Q_SIZE];         \
  uint8_t * volatile q##_head;                        \
  uint8_t * volatile q##_tail

#define QUEUE_EXTERN(q)                               \
  extern uint8_t q##_buf[];                           \
  extern uint8_t * const q##_end;                     \
  extern uint8_t * volatile q##_head;                 \
  extern uint8_t * volatile q##_tail

#define QUEUE_INIT(q)                                 \
  q##_head = q##_tail = q##_buf

#define QUEUE_NEXT(q)                                 \
  Q_NEXT(*q##_head, q##_buf, q##_end)

#define QUEUE_EMPTY(q)                                \
  Q_EMPTY(q##_head, q##_tail)

#define QUEUE_PUSH(q,c)                               \
	Q_PUSH(c, &q##_head, &q##_tail, q##_buf, q##_end)
  
#define QUEUE_POP_UNSAFE(q)                           \
  Q_POP_UNSAFE(&q##_head, q##_buf, q##_end)

#define QUEUE_POP(q,c)                                \
	Q_POP(c, &q##_head, q##_tail, q##_buf, q##_end)

#define QUEUE_PEEK_UNSAFE(q)                          \
  Q_PEEK_UNSAFE(q##_head)
  
#define QUEUE_PEEK(q,r)                               \
  Q_PEEK(r, &q##_head, q##_tail)

#define QUEUE_LENGTH(q)                               \
  Q_LENGTH(q##_head, q##_tail, q##_buf, q##_end)
  
#define QUEUE_FIND(q,f)                               \
  Q_FIND(f, q##_head, q##_tail, q##_buf, q##_end)

#endif  // __QUEUE_H__
